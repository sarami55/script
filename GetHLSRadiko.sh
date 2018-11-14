#!/usr/local/bin/bash
export PATH=$PATH:$HOME/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin
export LD_LIBRARY_PATH=$HOME/lib
export PERL5LIB="$HOME/lib/perl5/lib/perl5:$HOME/lib/perl5/lib/perl5/amd64-freebsd"


if [ $# -eq 4 ]; then
  OUTFILEPREFIX=$1
  RECTIMEMIN=$2
  CHANNEL=$3
  AREAID=$4
else
  echo "usage : $0 OUTFILEPREFIX RECTIMEMIN CHANNEL AREAID"
  exit 1;
fi
FFMPEG=$HOME/bin/ffmpeg
OUTFILEBASEPATH=$HOME/REC
OUTFILENAME=${OUTFILEBASEPATH}/`date '+%Y-%m-%d-%H%M'`-${CHANNEL}-${OUTFILEPREFIX}
FLVFILEEXT=".aac"
MARGINTIMEMIN=120
RECTIME=`expr ${RECTIMEMIN}  + ${MARGINTIMEMIN}`

cd ${OUTFILEBASEPATH}

keyfile=$HOME/bin/0Key-radiko.bin


##
0Random-radiko.pl $AREAID > mysetenv-$$.sh
if [ $? -ne 0 ]; then
	echo "ID error";
	rm mysetenv-$$.sh
	exit 1;
fi

##
source mysetenv-$$.sh
##
rm mysetenv-$$.sh
##


if [ -f auth1_fms_hls_$$__${OUTFILEPREFIX}_${CHANNEL} ]; then
  rm -f auth1_fms_hls_$$__${OUTFILEPREFIX}_${CHANNEL}
fi

##
#
# access auth1
#
wget  -q\
     --header="pragma: no-cache" \
     --header="X-Radiko-App: aSmartPhone7a" \
     --header="X-Radiko-App-Version: ${APPVER}" \
     --header="X-Radiko-User: user-${USERID}" \
     --header="X-Radiko-Device: ${DEVICE}" \
     --save-headers \
     --tries=10 \
     --retry-connrefused \
     --waitretry=5 \
     --timeout=10 \
     -O auth1_fms_hls_$$_${OUTFILEPREFIX}_${CHANNEL} \
     https://radiko.jp/v2/api/auth1

if [ $? -ne 0 ]; then
  echo "failed auth1 process"
  exit 1;
fi

#
# get partial key
#
authtoken=`cat auth1_fms_hls_$$_${OUTFILEPREFIX}_${CHANNEL} | perl -ne 'print $1 if(/x-radiko-authtoken: ([\w-]+)/i)'`
offset=`cat auth1_fms_hls_$$_${OUTFILEPREFIX}_${CHANNEL} | perl -ne 'print $1 if(/x-radiko-keyoffset: (\d+)/i)'`
length=`cat auth1_fms_hls_$$_${OUTFILEPREFIX}_${CHANNEL} | perl -ne 'print $1 if(/x-radiko-keylength: (\d+)/i)'`

partialkey=`dd if=$keyfile bs=1 skip=${offset} count=${length} 2> /dev/null | base64`

#echo "authtoken: ${authtoken} offset: ${offset} length: ${length} partialkey: $partialkey"

#rm -f auth1_fms_hls_$$_${OUTFILEPREFIX}_${CHANNEL}

if [ -f auth2_fms_hls_$$_${OUTFILEPREFIX}_${CHANNEL} ]; then
  rm -f auth2_fms_hls_$$_${OUTFILEPREFIX}_${CHANNEL}
fi

#
# access auth2
#
wget  -q\
     --header="pragma: no-cache" \
     --header="X-Radiko-App: aSmartPhone7a" \
     --header="X-Radiko-App-Version: ${APPVER}" \
     --header="X-Radiko-User: user-${USERID}" \
     --header="X-Radiko-Device: ${DEVICE}" \
     --header="X-Radiko-AuthToken: ${authtoken}" \
     --header="X-Radiko-PartialKey: ${partialkey}" \
     --header="X-Radiko-Location: ${GPSLocation}" \
     --header="X-Radiko-Connection: wifi" \
     --retry-connrefused \
     --waitretry=5 \
     --tries=10 \
     --timeout=10 \
     -O auth2_fms_hls_$$_${OUTFILEPREFIX}_${CHANNEL} \
     https://radiko.jp/v2/api/auth2

if [ $? -ne 0 -o ! -f auth2_fms_hls_$$_${OUTFILEPREFIX}_${CHANNEL} ]; then
  echo "failed auth2 process"
  exit 1;
fi

#echo "authentication success"

#auth_areaid=`cat auth2_fms_hls_$$_${OUTFILEPREFIX}_${CHANNEL} | perl -ne 'print $1 if(/^([^,]+),/i)'`
#echo "areaid: $auth_areaid"

rm -f auth2_fms_hls_$$_${OUTFILEPREFIX}_${CHANNEL}

#########
#########

wget -q "http://radiko.jp/v2/station/stream_smh_multi/${CHANNEL}.xml" -O ${CHANNEL}-$$.xml

stream_url=`echo "cat /urls/url[1]/playlist_create_url/text()" | xmllint --shell ${CHANNEL}-$$.xml | tail -2 | head -1`;

rm -f ${CHANNEL}-$$.xml


#echo $stream_url

CRLF=$(printf '\r\n')

#
# ffmpeg
#
RETRYCOUNT=0
while :
do
${FFMPEG} -loglevel verbose \
 	-headers "X-Radiko-AuthToken: ${authtoken}${CRLF}" \
	-i ${stream_url} \
	-t ${RECTIME} \
	-vn -acodec copy \
	${OUTFILENAME}${FLVFILEEXT}


  if [ `wc -c ${OUTFILENAME}${FLVFILEEXT} | awk '{print $1}'` -ge 10240 ]; then
    break
  elif [ ${RETRYCOUNT} -ge 5 ]; then
    echo "failed ffmpeg"
    exit 1;
  else
    RETRYCOUNT=`expr ${RETRYCOUNT} + 1`
  fi
done

#
#
#
tmpa=${OUTFILENAME}${FLVFILEEXT
tmpb=${OUTFILENAME}.m4a

filename=`basename $tmpa`
myfilename=`basename $tmpb`

cd $HOME/REC
${FFMPEG} -i $filename -vn -acodec copy \
	-metadata Comment="user/HLS_Radiko" \
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
#cp $working_dir/$outfile.gpg /home/user/www/quick/

FTP.sh $filename


rm -f $filename.zip $filename.gpg
exit 0;


