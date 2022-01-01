#!/bin/bash

cd /home/user/.gnupg

mv -f mega.ls.old.3 mega.ls.old.4
mv -f mega.ls.old.2 mega.ls.old.3
mv -f mega.ls.old mega.ls.old.2
mv -f mega.ls mega.ls.old

megals -R /Root/Public > mega.ls
diff -U 1 mega.ls.old.4 mega.ls > diff.txt


NOW=`date '+%Y/%m/%d'`;
OLD=`date -r mega.ls.old.4 '+%Y/%m/%d'`;

cat <<EOF > diff.html
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
<title>MEGA diff</title>
</head>
<body>
<BR>
<HR><BR>
<CENTER>MEGA.NZ DIFF from ${OLD} to ${NOW}</CENTER><BR><HR><BR>
<PRE>
EOF

cat diff.txt >> diff.html

cat <<EOF >> diff.html
</PRE>
<BR>
<BR>
</body>

</html>

EOF

#
scp -q diff.html user@t-user.com:/home/user/www/crk/
