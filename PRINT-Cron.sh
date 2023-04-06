#!/bin/sh
export PATH=$PATH:/home/user/bin:/sbin:/bin:/\usr/local/sbin:/usr/local/bin
export LANG=C

TARGET_DIR=/home/user/.gnupg

cd  $TARGET_DIR

PRINT-Cron-sub.sh > cron-t.html


#cp $TARGET_DIR/cron-t.html /home/user/www/WIKI/htmlinsert
scp -q cron-t.html user@www.t-user.com:/home/user/www/crk/


#rm -f /home/user/REC/*


exit 0;




