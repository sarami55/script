#!/usr/local/bin/bash
export PATH=$PATH:$HOME/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/\usr/local/sbin:/usr/local/bin
export LD_LIBRARY_PATH=$HOME/lib
export PERL5LIB="$HOME/lib/perl5/lib/perl5:$HOME/lib/perl5/lib/perl5/amd64-freebsd"

# args check
if [ $# -ne 4 ]; then
	echo "usage : $0 OUTFILE_SUFFIX REC_TIME(s) "\
	     "STREAM(V/A) BIWEEK(0/1)"
	exit 1;
fi

SUFFIX=AAG-$1
REC_TIME=$2
STREAM=$3
BIWEEK_F=$4

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
#
# ffmpeg
#
#
# cf. https://www.uniqueradio.jp/agplayer5/hls/mbr-ff.m3u8
#

hlsurl='https://www.uniqueradio.jp/agplayer5/hls/mbr-ff.m3u8'

#
REC_TIME=`expr ${REC_TIME}  + 180`

#
RETRYCOUNT=0
while :
do

	START=`date +%s`
	echo "start: $START" >> ${outfile}.log
	ffmpeg  -loglevel quiet \
		-reconnect 1 \
		-reconnect_at_eof 1 \
		-reconnect_streamed 1 \
		-reconnect_delay_max 2 \
		-i $hlsurl \
		-codec copy \
		-t ${REC_TIME} \
		-movflags faststart -bsf:a aac_adtstoasc \
		-y \
		${outfile}-${RETRYCOUNT}.mp4

	NOW=`date +%s`
	DUR=`expr ${NOW} - ${START}`
	DURTMP=`expr ${DUR} + 30`
	if [ ${DURTMP} -ge ${REC_TIME} ]; then
		echo "DUR: $DUR" >> ${outfile}.log
		echo "DURTMP: $DURTMP" >> ${outfile}.log
		echo "REC: $REC_TIME" >> ${outfile}.log
	    break
	elif [ ${RETRYCOUNT} -ge 5 ]; then
	    echo "failed ffmpeg"
	    TW.pl "failed ($SUFFIX)" > /dev/null
	    exit 1
	else
	    RETRYCOUNT=`expr ${RETRYCOUNT} + 1`
	fi
	echo "DUR: $DUR" >> ${outfile}.log
	echo "DURTMP: $DURTMP" >> ${outfile}.log
	echo "REC: $REC_TIME" >> ${outfile}.log
	REC_TIME=`expr ${REC_TIME} - ${DUR}`;
#	echo "re $REC_TIME"

done


####

for filename in ${outfile}-*.mp4; do

	#echo "file $filename"

####
	if ( [ $STREAM = 'V' -o $STREAM = 'v' ] ); then
		outfile=${filename}
	else
		outfile=`basename ${filename} .mp4`
		ffmpeg -i ${filename} -vn -acodec copy \
		       ${outfile}.m4a >/dev/null 2>/dev/null
		rm -f ${filename}
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


done

exit 0;



