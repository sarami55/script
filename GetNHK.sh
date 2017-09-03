#!/bin/bash
# args check
if [ $# -ne 6 ]; then
	echo "usage : $0 OUTFILE_SUFFIX  REC_TIME(s)  "\
	     "UPLOAD(0/1) COMMENT  DL_PASS  RM_PASS"
	exit 1;
fi

SUFFIX=$1
REC_TIME=$2
UPLOAD_F=$3
COMMENT=$4
DL_PASS=$5
RM_PASS=$6

working_dir=/home/user/REC
check_biweek_dir=/home/user/100

now=`date '+%Y-%m-%d-%H%M'`;
ftpdir=Public/Radio/`date '+%Y-%m'`;


REC_TIME=$(expr ${REC_TIME}  + 60);


cd $working_dir

outfile=$now-NHK-$1.m4a;


#
# rtmpdump
#
RETRYCOUNT=0
while :
do
	rtmpdump -q --rtmp rtmpe://netradio-r1-flash.nhk.jp \
        	 --app live \
	         --playpath NetRadio_R1_flash@63346 \
         --swfVfy http://www3.nhk.or.jp/netradio/files/swf/rtmpe_ver2015.swf \
		--live \
		--timeout 5 \
		-o $outfile \
	        --stop ${REC_TIME}

  
  if [ `wc -c $outfile | awk '{print $1}'` -ge 300000 ]; then
    break
  elif [ ${RETRYCOUNT} -ge 5 ]; then
    echo "failed rtmpdump"
    exit 1
  else
    RETRYCOUNT=`expr ${RETRYCOUNT} + 1`
  fi
  sleep 1;
done


#
#
#

gpg --options /home/user/.gnupg/opt.txt $outfile

DB=/home/user/.gnupg/Sessionkeys.db
key=`gpg -o /dev/null --batch --show-session-key $outfile.gpg 2>&1|
        perl -ne 'print $1 if (/gpg: session key:\s+.(\w+:\w+)/)'`
    
RANDOM=`od -vAn -N2 -tu2 < /dev/random`;
mytime=$(expr $RANDOM % 11);
sleep $mytime;
outasffile=`basename $outfile`
ssh user@t-user.com "sqlite3 $DB \"insert into sKey values('$outasffile.gpg', '$key');\""


FTP.sh $outfile

rm -f $outfile.gpg                                                                        
exit 0;


