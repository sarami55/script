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

hlsurl='https://fms2.uniqueradio.jp/agqr10/aandg3.m3u8'

#
REC_TIME=`expr ${REC_TIME}  + 180`

#

	i=${REC_TIME}
	((sec=i%60, min=(i%3600)/60, hrs=i/3600))
	timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)
	streamlink -Q \
		--hls-duration ${timestamp} \
		$hlsurl \
		best \
		-o ${outfile}.mp4  >/dev/null 2>/dev/null

####

for filename in ${outfile}.mp4; do

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



