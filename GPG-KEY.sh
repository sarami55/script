#!/bin/sh
export PATH=$PATH:/home/user/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/\usr/local/sbin:/usr/local/bin
export LD_LIBRARY_PATH=/home/user/lib
export PERL5LIB="/home/user/lib/perl5/lib/perl5:/home/user/lib/perl5/li\b/perl5/amd64-freebsd"

cat /home/user/.gnupg/gpg.conf >/home/user/.gnupg/opt.txt
gpg --no-secmem-warning --list-key |GetKey.pl >>/home/user/.gnupg/opt.txt

LIST-KEY.sh

exit 0;
