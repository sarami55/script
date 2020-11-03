#!/usr/local/bin/bash
export PATH=$PATH:$HOME/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/\usr/local/sbin:/usr/local/bin
export LD_LIBRARY_PATH=$HOME/lib
export PERL5LIB="$HOME/lib/perl5/lib/perl5:$HOME/lib/perl5/lib/perl5/amd64-freebsd"

# args check
if [ $# -ne 8 ]; then
	echo "usage : $0 OUTFILE_SUFFIX  REC_TIME(s)  "\
	     "STREAM(V/A)  UPLOAD(0/1) COMMENT  DL_PASS  RM_PASS  BIWEEK(0/1)"
	exit 1;
fi

SUFFIX=AAG-$1
REC_TIME=$2
STREAM=$3
UPLOAD_F=$4
COMMENT=$5
DL_PASS=$6
RM_PASS=$7
BIWEEK_F=$8

working_dir=$HOME/REC
check_biweek_dir=$HOME/100

now=`date '+%Y-%m-%d-%H%M'`;
ftpdir=Public/Radio/`date '+%Y-%m'`;

check_date=`date -v -1w '+%Y-%m-%d-%H%M'`;
check_file=$check_date-$SUFFIX

if ( [ $BIWEEK_F -eq 9 ] ); then
	today=`date -v -6H '+%d'`;
	weekly=`date -v -6H '+%u'`;

        checkmonday=$(expr $today - $weekly  + 1);

        if ( [ $checkmonday -le 0 ] ); then
                exit 0;
        fi
        if ( [ $checkmonday -ge 8 ] && [ $checkmonday -le 14 ] ); then
                exit 0;
        fi
        if ( [ $checkmonday -ge 22 ] && [ $checkmonday -le 28 ] ); then
                exit 0;
        fi
fi

if ( [ $BIWEEK_F -eq 1 ] && [ -f $check_biweek_dir/$check_file ] ); then 
	rm -f $check_biweek_dir/$check_file;
	exit 0;
fi

cd $working_dir

outfile=$now-$SUFFIX;

[ $BIWEEK_F -eq 1 ] && touch "$check_biweek_dir/$outfile";


######
#
SARAMITMP=/tmp/auau.$$
SARAMISRC=/tmp/bubu.$$

(sleep 120; wget -q https://www.uniqueradio.jp/aandg -O $SARAMITMP;
cat $SARAMITMP | sed 's/var//' | sed 's/ = /=/' >$SARAMISRC) &


#
# ffmpeg
#
#
# cf. https://www.uniqueradio.jp/agplayer5/hls/mbr-ff.m3u8
#

hlsurl='https://www.uniqueradio.jp/agplayer5/hls/mbr-ff.m3u8'

#
#
RETRYCOUNT=0
while :
do

	ffmpeg -i $hlsurl \
		-codec copy \
		-t ${REC_TIME} \
		${outfile}-tmp.mp4

	if [ `wc -c ${outfile}-tmp.mp4 | awk '{print $1}'` -ge 10240 ]; then
	    break
	elif [ ${RETRYCOUNT} -ge 5 ]; then
	    echo "failed ffmpeg"
	    TW.pl "failed ($SUFFIX)" > /dev/null
	    rm -f $SARAMITMP
	    rm -f $SARAMISRC
	    rm -f $FMSLIST
	    exit 1
	  else
	    RETRYCOUNT=`expr ${RETRYCOUNT} + 1`
	  fi
	  sleep 5;
	  REC_TIME=`expr ${REC_TIME} - 5`;
done

####
source $SARAMISRC

rm -f $SARAMITMP
rm -f $SARAMISRC
rm -f $FMSLIST

MYTITLE=`echo $Program_name | tr % = | nkf -WwmQ`
MYART=`echo $Program_personality | tr % = | nkf -WwmmQ`
MYCOM=`echo $Program_text | tr % = | nkf -WwmQ`


####
if ( [ $STREAM = 'V' -o $STREAM = 'v' ] ); then
	ffmpeg -i ${outfile}-tmp.mp4 -codec copy -metadata Title="$MYTITLE" \
	       -metadata Comment="x $MYCOM" -metadata Artist="$MYART"  \
               $outfile.mp4 >/dev/null 2>/dev/null
	rm -f ${outfile}-tmp.mp4
	outfile=${outfile}.mp4
else
	ffmpeg -i ${outfile}-tmp.mp4 -vn -acodec copy -metadata title="$MYTITLE" \
	       -metadata artist="$MYART" -metadata comment="x $MYCOM" \
	       ${outfile}.m4a >/dev/null 2>/dev/null
	rm -f ${outfile}-tmp.mp4
	outfile=${outfile}.m4a
fi


gpg --options $HOME/.gnupg/opt.txt $outfile

DB=$HOME/.gnupg/Sessionkeys.db
key=`gpg -o /dev/null --batch --show-session-key $outfile.gpg 2>&1|
	perl -ne 'print $1 if (/gpg: session key:\s+.(\w+:\w+)/)'`

RANDOM=`od -vAn -N2 -tu2 < /dev/random`;      
mytime=$(expr $RANDOM % 11);      
sleep $mytime;

sqlite3 $DB "insert into sKey values('$outfile.gpg', '$key');"  

Update-crk.sh $working_dir/$outfile.gpg
#cp $working_dir/$outfile.gpg /home/user/www/quick/


FTP.sh $outfile

rm -f $outfile.gpg

exit 0;



