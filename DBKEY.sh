#!/bin/sh

# args check
if [ $# -ne 1 ]; then
        echo "usage : $0 GPGFILE"
        exit 1;
fi                 


DB=/home/user/.gnupg/Sessionkeys.db
key=`gpg -o /dev/null --batch --show-session-key $1 2>&1|
        perl -ne 'print $1 if (/gpg: session key:\s+.(\w+:\w+)/)'`

echo "sqlite3 $DB \"insert into sKey values('$1', '$key');\""

sqlite3 $DB "insert into sKey values('$1', '$key');"

exit 0;

