#!/bin/sh
PATH=$PATH:/home/user/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin
export LD_LIBRARY_PATH=/home/user/lib

com=$2;
dlpass=$3;
rmpass=$4;

filename=`basename $1`
upfile=`basename $1 \.flv`.zip


cd /home/user/REC
zip  -q $upfile $filename

curl -s \
	-F "file=@$upfile" \
	-F "comment=$com" \
	-F "download_pass=$dlpass" \
	-F "remove_pass=$rmpass" \
	-F 'code_pat=µþ' \
	http://www7.puny.jp/uploader2/upload/

rm -f $upfile









