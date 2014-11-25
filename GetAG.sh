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

(sleep 120; wget -q http://www.uniqueradio.jp/aandg -O $SARAMITMP;
cat $SARAMITMP | sed 's/var//' | sed 's/ = /=/' >$SARAMISRC) &


#
# rtmpdump
#
#
# cf. http://www.uniqueradio.jp/agplayerf/getfmsList.xml
#
#
RETRYCOUNT=0
while :
do

FMSLIST=/tmp/cucu.$$
rm -f $FMSLIST

	wget -q  http://www.uniqueradio.jp/agplayerf/getfmsListHD.php \
		-O $FMSLIST

	stream_url=`echo "cat /ag/serverlist/serverinfo[1]/server/text()" | 
		xmllint -shell $FMSLIST | tail -2 |head -1 `

	index=(`echo ${stream_url} | 
	perl -pe 's!^fms(\d+)\.uniqueradio\.jp/\?rtmp://fms-base(\d+)\.mitene\.ad\.jp!$1 $2!'`)

#	fms1.uniqueradio.jp/?rtmp://fms-base2.mitene.ad.jp

	app=`echo cat "/ag/serverlist/serverinfo[1]/app/text()" | 
		xmllint -shell $FMSLIST | tail -2 |head -1 `


	stream=`echo "cat /ag/serverlist/serverinfo[1]/stream/text()" | 
		xmllint -shell $FMSLIST | tail -2 |head -1 `

	tmpurl="rtmpe://fms${index[0]}.uniqueradio.jp/";
	outfile=${outfile}-${index[0]};	

	tmppath="?rtmp://fms-base${index[1]}.mitene.ad.jp/${app}/";
	outfile=${outfile}${index[1]};

	
	outfile=${outfile}${stream};

#	echo $tmpurl
#	echo $tmppath
#	echo $outfile


	rtmpdump -q -vr $tmpurl \
	 -a $tmppath \
	 -f "WIN 15,0,0,223" \
         -W "http://www.uniqueradio.jp/agplayerf/LIVEPlayer-HD0318.swf" \
         -p "http://www.uniqueradio.jp/agplayerf/newplayerf2-win.php" \
	 -C B:0 -y ${stream} \
         --stop ${REC_TIME} \
	 --timeout 30 \
	 -o $outfile

#  if [ $? -ne 1 -o `wc -c $outfile | awk '{print $1}'` -ge 10240 ]; then
  if [ `wc -c $outfile | awk '{print $1}'` -ge 10240 ]; then
    break
  elif [ ${RETRYCOUNT} -ge 10 ]; then
    echo "failed rtmpdump"
    TW.pl "failed ($outfile)" > /dev/null
    exit 1
  else
    RETRYCOUNT=`expr ${RETRYCOUNT} + 1`
  fi
  sleep 1;
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
	ffmpeg -i $outfile -codec copy -metadata Title="$MYTITLE" \
	       -metadata Comment="x $MYCOM" -metadata Artist="$MYART"  \
               $outfile.mp4 >/dev/null 2>/dev/null
	rm -f $outfile
	outfile=$outfile.mp4
else
	ffmpeg -i $outfile -vn -acodec copy -metadata title="$MYTITLE" \
	       -metadata artist="$MYART" -metadata comment="x $MYCOM" \
	       $outfile.m4a >/dev/null 2>/dev/null
	rm -f $outfile
	outfile=$outfile.m4a
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
#cp $working_dir/$outfile.gpg /home/auau1234/www/quick/


FTP.sh $outfile

rm -f $outfile.gpg

exit 0;



