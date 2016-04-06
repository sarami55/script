#!/bin/sh
export PATH=$PATH:/home/user/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/\usr/local/sbin:/usr/local/bin
export LD_LIBRARY_PATH=/home/user/lib
export PERL5LIB="/home/user/lib/perl5/lib/perl5:/home/user/lib/perl5/li\b/perl5/perl5/i386-freebsd-64int"

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

ftpaccount_pass='user@livedoor.com':PASS;
ftpurl="ftp://ftp.4shared.com";
working_dir=/home/user/REC
posted_dir=/home/user/000
check_biweek_dir=/home/user/100

now=`date '+%Y-%m-%d-%H%M'`;
comment_date=`date '+%m%d'`;
ftpdir=Public/Radio/`date '+%Y-%m'`;
REC_TIME=$(expr ${REC_TIME}  + 60);



cd $working_dir

outfile=$now-$1.m4a;
upfile=$outfile.zip;



#
# rtmpdump
#
RETRYCOUNT=0
while :
do
	rtmpdump -q --rtmp "rtmpe://netradio-r1-flash.nhk.jp" \
		--playpath 'NetRadio_R1_flash@63346' \
		--app "live" \
        -W "http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf?ver.2" \
	--swfsize 300567 \
--swfhash "aca5e184b4f4090a1433c3e6323e2e0c29d3a0abb70a45a9dfa7ad6da9dc202e" \
       --live -C B:0 --timeout 5 \
		--flv $outfile \
	        --stop ${REC_TIME}

  
  if [ `wc -c $outfile | awk '{print $1}'` -ge 384000 ]; then
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

#zip  -q -P $DL_PASS $upfile $outfile
gpg --options /home/user/.gnupg/opt.txt $outfile

posturl=`PostURL.pl $upfile`;

if ( [ $posturl = 'NONE' ] ); then
        UPLOAD_F=0;
fi

if ( [ $UPLOAD_F -eq 1 ] ); then
        tmpfile=/tmp/aaa.$$
        curl -s \
                -F "file=@$upfile;type=application/x-zip-compressed" \
                -F "comment=$COMMENT-$comment_date" \
                -F "download_pass=$DL_PASS" \
                -F "remove_pass=$RM_PASS" \
		-F 'code_pat=µþ' \
                --retry 5 \
                --retry-delay 10 \
                $posturl >$tmpfile

        echo $posturl > $posted_dir/$upfile
        GetId.pl $tmpfile > $posted_dir/$upfile.info

        POSTURL=`cat $posted_dir/$upfile | sed 's/\/upload\//\/download\//'`
        ID=`cat $posted_dir/$upfile.info`
        TW.pl "[$upfile] is uploaded.  $POSTURL$ID.zip" >/dev/null         
        rm -f $tmpfile;
fi                                   



DB=/home/user/.gnupg/Sessionkeys.db

key=`gpg -o /dev/null --batch --show-session-key $outfile.gpg 2>&1|
        perl -ne 'print $1 if (/gpg: session key:\s+.(\w+:\w+)/)'`

sqlite3 $DB "insert into sKey values('$outfile.gpg', '$key');"

Update-crk.sh $working_dir/$outfile.gpg

FTP.sh $outfile

rm -f $upfile $outfile.gpg                                                                        
exit 0;


