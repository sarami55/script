#!/usr/local/bin/bash
export PATH=$PATH:$HOME/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin
export LD_LIBRARY_PATH=$HOME/lib
export PERL5LIB="$HOME/lib/perl5/lib/perl5:$HOME/lib/perl5/li\b/perl5/perl5/i386-freebsd-64int"

POSTURL="http://www8.puny.jp/uploader/upload/"



if [ $# -eq 6 ]; then
  OUTFILEPREFIX=$1
  RECTIMEMIN=$2
  CHANNEL=$3
else
  echo "usage : $0 OUTFILEPREFIX RECTIMEMIN CHANNEL"
  exit 1
fi

OUTFILEPREFIX=$1
RECTIMEMIN=$2
CHANNEL=$3

RTMPDUMP=$HOME/bin/rtmpdump
FFMPEG=$HOME/ffmpeg

OUTFILEBASEPATH=$HOME/REC
OUTFILENAME=${OUTFILEBASEPATH}/`date '+%Y-%m-%d-%H%M'`-${CHANNEL}-${OUTFILEPREFIX}
AUAUDIR=`date '+%Y-%m'`
FLVFILEEXT=".flv"
AACFILEEXT=".aac"

auau=`date '+%m%d'`

#sleep 30

MARGINTIMEMIN=80
#RECTIME=`expr ${RECTIMEMIN}  + ${MARGINTIMEMIN} \* 2 \* 15`

RECTIME=`expr ${RECTIMEMIN}  + ${MARGINTIMEMIN}`

cd ${OUTFILEBASEPATH}

playerurl=http://radiko.jp/player/swf/player_4.0.1.00.swf
playerfile=$HOME/bin/player.$$.swf
keyfile=$HOME/bin/authkey.$$.png




#
# get player
#
if [ ! -f $playerfile ]; then
  wget -q \
	--tries=13 \
	--retry-connrefused \
	--waitretry=4 \
	--timeout=10 \
	-O $playerfile $playerurl

  if [ $? -ne 0 ]; then
    echo "failed get player"
    exit 1
  fi
fi

#
# get keydata (need swftools)
#
if [ ! -f $keyfile ]; then
  swfextract -b 14 $playerfile -o $keyfile

  if [ ! -f $keyfile ]; then
    echo "failed get keydata"
    exit 1
  fi
fi

if [ -f auth1_fms_${OUTFILEPREFIX}_${CHANNEL} ]; then
  rm -f auth1_fms_${OUTFILEPREFIX}_${CHANNEL}
fi

#
# access auth1_fms
#
wget -q \
     --header="pragma: no-cache" \
     --header="X-Radiko-App: pc_1" \
     --header="X-Radiko-App-Version: 2.0.1" \
     --header="X-Radiko-User: test-stream" \
     --header="X-Radiko-Device: pc" \
     --post-data='\r\n' \
     --no-check-certificate \
     --save-headers \
     --tries=10 \
     --retry-connrefused \
     --waitretry=5 \
     --timeout=10 \
     -O auth1_fms_${OUTFILEPREFIX}_${CHANNEL} \
     https://radiko.jp/v2/api/auth1_fms

if [ $? -ne 0 ]; then
  echo "failed auth1 process"
  exit 1
fi

#
# get partial key
#
authtoken=`cat auth1_fms_${OUTFILEPREFIX}_${CHANNEL} | perl -ne 'print $1 if(/x-radiko-authtoken: ([\w-]+)/i)'`
offset=`cat auth1_fms_${OUTFILEPREFIX}_${CHANNEL} | perl -ne 'print $1 if(/x-radiko-keyoffset: (\d+)/i)'`
length=`cat auth1_fms_${OUTFILEPREFIX}_${CHANNEL} | perl -ne 'print $1 if(/x-radiko-keylength: (\d+)/i)'`

partialkey=`dd if=$keyfile bs=1 skip=${offset} count=${length} 2> /dev/null | base64`

#echo "authtoken: ${authtoken} \noffset: ${offset} length: ${length} \npartialkey: $partialkey"

rm -f auth1_fms_${OUTFILEPREFIX}_${CHANNEL}

if [ -f auth2_fms_${OUTFILEPREFIX}_${CHANNEL} ]; then
  rm -f auth2_fms_${OUTFILEPREFIX}_${CHANNEL}
fi

#
# access auth2_fms
#
wget -q \
     --header="pragma: no-cache" \
     --header="X-Radiko-App: pc_1" \
     --header="X-Radiko-App-Version: 2.0.1" \
     --header="X-Radiko-User: test-stream" \
     --header="X-Radiko-Device: pc" \
     --header="X-Radiko-Authtoken: ${authtoken}" \
     --header="X-Radiko-Partialkey: ${partialkey}" \
     --post-data='\r\n' \
     --no-check-certificate \
     --retry-connrefused \
     --waitretry=5 \
     --tries=10 \
     --timeout=10 \
     -O auth2_fms_${OUTFILEPREFIX}_${CHANNEL} \
     https://radiko.jp/v2/api/auth2_fms

if [ $? -ne 0 -o ! -f auth2_fms_${OUTFILEPREFIX}_${CHANNEL} ]; then
  echo "failed auth2 process"
  exit 1
fi

#echo "authentication success"

areaid=`cat auth2_fms_${OUTFILEPREFIX}_${CHANNEL} | perl -ne 'print $1 if(/^([^,]+),/i)'`
#echo "areaid: $areaid"

rm -f auth2_fms_${OUTFILEPREFIX}_${CHANNEL}



if [ -f ${CHANNEL}.xml ]; then
	rm -f ${CHANNEL}.xml
fi

wget -q "http://radiko.jp/v2/station/stream/${CHANNEL}.xml";
stream_url=`echo "cat /url/item[1]/text()" | xmllint --shell ${CHANNEL}.xml | tail -2 | head -1`;
url_parts=(`echo ${stream_url} | perl -pe 's!^(.*)://(.*?)/(.*)/(.*?)$/!$1://$2 $3 $4!'`)

rm -f ${CHANNEL}.xml

#
# rtmpdump
#
RETRYCOUNT=0
while :
do
  ${RTMPDUMP} -q \
	      -r ${url_parts[0]} \
	      --app ${url_parts[1]} \
	      --playpath ${url_parts[2]} \
              -W $playerurl \
              -C S:"" -C S:"" -C S:"" -C S:$authtoken \
              --live \
              --flv ${OUTFILENAME}${FLVFILEEXT} \
              --stop ${RECTIME}

  if [ $? -ne 1 -o `wc -c ${OUTFILENAME}${FLVFILEEXT} | awk '{print $1}'` -ge 10240 ]; then
    break
  elif [ ${RETRYCOUNT} -ge 10 ]; then
    echo "failed rtmpdump"
    exit 1
  else
    RETRYCOUNT=`expr ${RETRYCOUNT} + 1`
  fi
done

rm -f $playerfile $keyfile

#
#
#
tmpa=${OUTFILENAME}${FLVFILEEXT}
tmpb=${OUTFILENAME}.m4a
com=$4;
dlpass=$5;
rmpass=$6;

filename=`basename $tmpa`
myfilename=`basename $tmpb`

cd $HOME/REC
ffmpeg -i $filename -vn -acodec copy -metadata Comment="x" \
	$myfilename >/dev/null 2>/dev/null
rm -f $filename
filename=$myfilename

gpg --options $HOME/.gnupg/opt.txt $filename
DB=$HOME/.gnupg/Sessionkeys.db
key=`gpg -o /dev/null --batch --show-session-key $filename.gpg 2>&1|
        perl -ne 'print $1 if (/gpg: session key:\s+.(\w+:\w+)/)'`

RANDOM=`od -vAn -N2 -tu2 < /dev/random`;
mytime=$(expr $RANDOM % 11);
sleep $mytime;

outasffile=`basename $filename`
sqlite3 $DB "insert into sKey values('$outasffile.gpg', '$key');"

Update-crk.sh $OUTFILEBASEPATH/$outasffile.gpg

FTP.sh $filename


rm -f $filename.zip $filename.gpg
exit 0;


