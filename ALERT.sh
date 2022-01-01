#!/bin/sh
export PATH=$PATH:/home/user/bin

#================================================================
# check web server
#
# wget option
# -nv : no verbose 
# -S  : print server response
# -t  : tries number 
# -T  : timeout seconds
# --spider             : don't download anything.
# --http-user=USER     : set http user to USER.
# --http-password=PASS : set http password to PASS.
#
# grep option
# -c : only print a count of matching lines per FILE
#================================================================

# parameter
URL="https://dl.sarami.info/"
TRY=1
TIMEOUT=60
SUBJECT="Web_Server_Failed"
MAILTO="user@gmail.com tetsuya@t-user.com"

# check
check=` wget -nv -S --spider -t $TRY --timeout $TIMEOUT  $URL     2>&1|grep -c "200 OK"`

if [ $check != 2 ]
then
	echo $URL | mail -s $SUBJECT $MAILTO
	tw.pl "現在 dl.sarami.info がダウンしています。" >/dev/null
	line.sh "現在 dl.sarami.info がダウンしています。"
fi


