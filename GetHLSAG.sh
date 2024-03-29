#!/bin/bash
export PATH=$PATH:$HOME/bin


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

check_date=`date -d '1 week ago' '+%Y-%m-%d-%H%M'`;
check_file=$check_date-$SUFFIX

if ( [ $BIWEEK_F -eq 9 ] ); then
	today=`date -d '6 hour ago' '+%d'`;
	weekly=`date -d ' 6 hour ago' '+%u'`;

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
#	mbr-0.m3u8  chrome?
#   mbr-1.m3u8  edge
#	mbr-ff.m3u8 firefox
#
#	https://hls-base1.mitene.ad.jp/agqr1/iphone/3Gs.m3u8
#	https://fms2.uniqueradio.jp/agqr1/iphone/3Gs.m3u8
#	https://fms2.uniqueradio.jp/agqr10/aandg1.m3u8
#	https://fms2.uniqueradio.jp/agqr10/aandg3.m3u8
#
#

hlsurl=' https://www.uniqueradio.jp/agplayer5/hls/mbr-ff.m3u8'

#
REC_TIME=`expr ${REC_TIME}  + 180`

#
RETRYCOUNT=0
while :
do

	START=`date +%s`
#	echo "start: $START" >> ${outfile}.log
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
	DURTMP=`expr ${DUR} + 60`
	if [ ${DURTMP} -ge ${REC_TIME} ]; then
#		echo "DUR: $DUR" >> ${outfile}.log
#		echo "DURTMP: $DURTMP" >> ${outfile}.log
#		echo "REC: $REC_TIME" >> ${outfile}.log
	    break
	elif [ ${RETRYCOUNT} -ge 10 ]; then
	    echo "failed ffmpeg"
	    TW.pl "failed ($SUFFIX)" > /dev/null
	    exit 1
	else
	    RETRYCOUNT=`expr ${RETRYCOUNT} + 1`
	fi

#	echo "DUR: $DUR" >> ${outfile}.log
#	echo "DURTMP: $DURTMP" >> ${outfile}.log
#	echo "REC: $REC_TIME" >> ${outfile}.log
	REC_TIME=`expr ${REC_TIME} - ${DUR}`
#	echo "recon REC: $REC_TIME" >> ${outfile}.log

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

	DB=/home/user/.gnupg/Sessionkeys.db
	key=`gpg -o /dev/null --batch --show-session-key $outfile.gpg 2>&1|
		perl -ne 'print $1 if (/gpg: session key:\s+.(\w+:\w+)/)'`

	RANDOM=`od -vAn -N2 -tu2 < /dev/random`;      
	mytime=$(expr $RANDOM % 11);      
	sleep $mytime;

	ssh user@t-user.com "sqlite3 $DB \"insert into sKey values('$outfile.gpg', '$key');\""

#	sqlite3 $DB "insert into sKey values('$outfile.gpg', '$key');"  

#	Update-crk.sh $working_dir/$outfile.gpg
	#cp $working_dir/$outfile.gpg /home/user/www/quick/


	sleep 10
	FTP.sh $outfile

	rm -f $outfile.gpg


done

exit 0;



