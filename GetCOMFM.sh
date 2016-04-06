#!/bin/sh
export PATH=$PATH:/home/user/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/\usr/local/sbin:/usr/local/bin
export LD_LIBRARY_PATH=/home/user/lib
export PERL5LIB="/home/user/lib/perl5/lib/perl5:/home/user/lib/perl5/li\b/perl5/perl5/i386-freebsd-64int"

# args check
if [ $# -ne 8 ]; then
	echo "usage : $0 OUTFILE_SUFFIX  REC_TIME(s)  "\
	     "STREAM(V/A)  UPLOAD(0/1) COMMENT  DL_PASS  RM_PASS  BIWEEK(0/1)"
	exit 1;
fi

SUFFIX=$1
REC_TIME=$2
STREAM=$3
UPLOAD_F=$4
COMMENT=$5
DL_PASS=$6
RM_PASS=$7
BIWEEK_F=$8

working_dir=/home/user/REC
posted_dir=/home/user/000
check_biweek_dir=/home/user/100

now=`date '+%Y-%m-%d-%H%M'`;
comment_date=`date '+%m%d'`;

check_date=`date -v -1w '+%Y-%m-%d-%H%M'`;
check_file=$check_date-fix-$SUFFIX.asf

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

outfile=$now-$1.asf;
outasffile=$now-FMS-$1.asf;
upfile=$now-fix-$1-AG.asf.zip;

[ $BIWEEK_F -eq 1 ] && touch "$check_biweek_dir/$outasffile";

#####
msdlretry=0;
while :
do
	rtspurl=http://www.fmsagami.co.jp/asx/fmsagami.asx

	msdl -a 10 -q  --stream-timeout $REC_TIME \
	     -o  $working_dir/$outfile \
	     $rtspurl

	if ( [ $? -eq 0 ] ); then break; fi

	msdlretry=$(expr $msdlretry + 1);
	if ( [ $msdlretry -ge 5 ] ); then echo "MSDL ERROR"; exit 1; fi
#	echo $rtspurl $msdlretry;
	sleep 5;
done

mv fmsagami_simul $outfile

####

#echo $sid | FreeMe2 2 $outfile 2>/dev/null

####
if ( [ $STREAM = 'V' -o $STREAM = 'v' ] ); then
	wine asfbin -q -i $outfile -o $outasffile>/dev/null;
else
	wine asfbin -q -nostr 2 -i $outfile -o $outasffile>/dev/null;
fi

rm -f $outfile fmsagami.asx

gpg --options /home/user/.gnupg/opt.txt $outasffile


DB=/home/user/.gnupg/Sessionkeys.db
key=`gpg -o /dev/null --batch --show-session-key $outasffile.gpg 2>&1|
	perl -ne 'print $1 if (/gpg: session key:\s+.(\w+:\w+)/)'`

RANDOM=`od -vAn -N2 -tu2 < /dev/random`;      
mytime=$(expr $RANDOM % 11);      
sleep $mytime;

sqlite3 $DB "insert into sKey values('$outasffile.gpg', '$key');"  

Update-crk.sh $working_dir/$outasffile.gpg

FTP.sh $outasffile

rm -f  $outasffile.gpg

exit 0;
