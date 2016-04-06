#!/bin/sh
export PATH=$PATH:$HOME/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin
export LD_LIBRARY_PATH=$HOME/lib
export PERL5LIB="$HOME/lib/perl5/lib/perl5:$HOME/lib/perl5/lib/perl5/amd64-freebsd"
export PYTHONPATH=/home/user/lib/python2.7/site-packages
export LANG=C

outfile=$1
ftpaccount_pass='user@yahoo.co.jp':PASS;

#curl -s \
#        -T "$outfile.gpg" \
#        -u "$ftpaccount_pass" \
#        --retry 10 \
#        --retry-delay 10 \
#        --connect-timeout 120 \
#	--ftp-create-dirs \
#        ftp://ftp.4shared.com/Public/Radio/`date -v -6H '+%Y-%m'`/ >/dev/null



curl -s \
        -T "$outfile.gpg" \
        -u 'user:PASS' \
        --retry 10 \
        --retry-delay 10 \
        --connect-timeout 120 \
	--ftp-create-dirs \
        ftp://radio.sarami.info/www/Public/Radio/`date -v -6H '+%Y-%m'`/`date -v -6H '+%a'`/ >/dev/null

#bypy.py upload $outfile.gpg  Radio/`date -v -6H '+%Y-%m'`/`date -v -6H '+%a'`/ >/dev/null



myurl=http://dl2.sarami.info/Radio/`date -v -6H '+%Y-%m'`/`date -v -6H '+%a'`/$outfile.gpg

TW.pl "[$outfile.gpg] is uploaded on $myurl" >/dev/null         

exit 0;



