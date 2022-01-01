#!/bin/sh
export PATH=$PATH:/home/user/bin

NOW=`date '+%H:%M on %Y/%m/%d'`;

cat <<EOF
<HTML>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<META NAME="ROBOTS" CONTENT="NOINDEX,NOFOLLOW,NOARCHIVE">
<META NAME="LIBWWW-PERL" CONTENT="NOINDEX,NOFOLLOW,NOARCHIVE">
<META HTTP-EQUIV="ROBOTS" CONTENT="NOINDEX,NOFOLLOW,NOARCHIVE">
<META HTTP-EQUIV="" CONTENT="NOINDEX,NOFOLLOW,NOARCHIVE">
<META name="robot-control" content="deny-all">
<META name="robot-control" content="deny-quote">
<META name="robot-control" content="deny-analysis">
<title>Crontab</title>
</head>
<body>
<BR>
<HR><BR>
<CENTER>dl0 Crontab at ${NOW}</CENTER><BR><HR><BR>
<PRE>
EOF

crontab -l | sed 's/user/user/g'| sed 's/auau/PASS/g'| sed 's/tetsuya/USER/g'| sed 's/t-user/domain/g'| sed 's/user/USER/g'


cat <<EOF
</PRE>
<BR>
<BR>
</body>

</html>

EOF
