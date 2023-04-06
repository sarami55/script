#!/bin/bash
export PATH=$PATH:$HOME/bin:$HOME/.local/bin


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
#	https://icraft.hs.llnwd.net/agqr10/aandg1.m3u8
#
hlsurl='https://www.uniqueradio.jp/agapps/hls/cdn.m3u8'
#hlsurl='https://www.uniqueradio.jp/agplayer5/hls/mbr-ff.m3u8'
#hlsurl='https://fms2.uniqueradio.jp/agqr10/aandg1.m3u8'
#hlsurl='https://icraft.hs.llnwd.net/agqr10/aandg1.m3u8'
#
REC_TIME=`expr ${REC_TIME}  + 180`

#
RETRYCOUNT=0
while :
do 
	T_START=`date +%s`
	i=${REC_TIME}
	((sec=i%60, min=(i%3600)/60, hrs=i/3600))
	timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)
    streamlink -Q --retry-streams 3 --retry-max 5 --retry-open 3\
	    --stream-segment-attempts 5 --stream-segment-threads 3\
		--hls-duration ${timestamp} \
        $hlsurl \
        best \
        -o ${outfile}-${RETRYCOUNT}.mp4  >/dev/null 2>/dev/null


	T_NOW=`date +%s`
	DUR=`expr ${T_NOW} - ${T_START}`
	DURTMP=`expr ${DUR} + 60`
    if [ ${DURTMP} -ge ${REC_TIME} ]; then
		break
	elif [ ${RETRYCOUNT} -ge 10 ]; then
		echo "streamlink error"
		exit 1
	fi

	RETRYCOUNT=`expr ${RETRYCOUNT} + 1`
	REC_TIME=`expr ${REC_TIME} - ${DUR}`

	SSS=`expr ${RETRYCOUNT} % 2`
#	if [ ${SSS} -eq 1 ]; then
#		hlsurl='https://fms2.uniqueradio.jp/agqr10/aandg3.m3u8'
#	else
#		hlsurl='https://fms2.uniqueradio.jp/agqr10/aandg1.m3u8'
#	fi

done

####

for filename in ${outfile}-*.mp4; do

	#echo "file $filename"

####
   if ( [ $STREAM = 'V' -o $STREAM = 'v' ] ); then
        outfile=${filename}
        mv $outfile tmp-${outfile}
        ffmpeg -i tmp-${outfile} -codec copy \
            $outfile >/dev/null 2>/dev/null
        rm -f tmp-${outfile}
    else
        outfile=`basename ${filename} .mp4`
        ffmpeg -i ${filename} -vn -acodec copy \
               ${outfile}.m4a >/dev/null 2>/dev/null
        rm -f ${filename}
        outfile=${outfile}.m4a
    fi

	FTP.sh $outfile

done

exit 0;

