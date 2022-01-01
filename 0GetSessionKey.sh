#!/bin/sh

# args check
if [ $# -ne 1 ]; then
        echo "usage : $0 GPGFILE"
        exit 1;
fi                 

##gpg --options /home/user/.gnupg/opt.txt $1

file=`basename $1`


DB=/home/user/.gnupg/Sessionkeys.db
key=`gpg -o /dev/null --batch --show-session-key $1.gpg 2>&1|
        perl -ne 'print $1 if (/gpg: session key:\s+.(\w+:\w+)/)'`

echo "sqlite3 $DB \"insert into sKey values('$file.gpg', '$key');\""
ssh user@t-user.com "sqlite3 $DB \"insert into sKey values('$file.gpg', '$key');\""


exit 0;

