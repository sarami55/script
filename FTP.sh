#!/bin/sh
export PATH=$PATH:$HOME/bin
export LANG=C

outfile=$1
MYDIR=/home/user/www/Public/Radio/
DAY=`LC_ALL=C date -d '6 hour ago' '+%Y-%m-%d-%a'`
OLD=`LC_ALL=C date -d '8 days ago' '+%Y-%m-%d-%a'`

MEDIR=`LC_ALL=C date -d '6 hour ago' '+%Y-%m'`/`LC_ALL=C date -d '6 hour ago' '+%a'`
DEST=/Public/Radio/sarami/${MEDIR}/

TAR=${MYDIR}${DAY}
OTAR=${MYDIR}${OLD}

if [ ! -d $TAR ]; then
	mkdir $TAR
fi
if [  -d $OTAR ]; then
	rm -rf $OTAR
fi

cp $outfile ${TAR}/ >/dev/null
mega-put -c -q  $outfile ${DEST}

exit 0;
