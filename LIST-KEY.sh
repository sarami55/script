#!/bin/sh
export PATH=$PATH:/home/user/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/\usr/local/sbin:/usr/local/bin
export LD_LIBRARY_PATH=/home/user/lib
export PERL5LIB="/home/user/lib/perl5/lib/perl5:/home/user/lib/perl5/li\b/perl5/perl5/i386-freebsd-64int"
export LANG=C;

NOW=`date '+%H:%M on %Y/%m/%d'`;

cat <<EOF >/home/user/.gnupg/list.html
<HTML>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<META NAME="" CONTENT="NOINDEX,NOFOLLOW,NOARCHIVE">
<META NAME="GOOGLEBOT" CONTENT="NOINDEX,NOFOLLOW,NOARCHIVE">
<META NAME="ROBOTS" CONTENT="NOINDEX,NOFOLLOW,NOARCHIVE">
<META NAME="LIBWWW-PERL" CONTENT="NOINDEX,NOFOLLOW,NOARCHIVE">
<META HTTP-EQUIV="ROBOTS" CONTENT="NOINDEX,NOFOLLOW,NOARCHIVE">
<META HTTP-EQUIV="" CONTENT="NOINDEX,NOFOLLOW,NOARCHIVE">
<META name="robot-control" content="deny-all">
<META name="robot-control" content="deny-quote">
<META name="robot-control" content="deny-analysis">
<title>Registered PUB key List</title>
</head>
<body>
<BR>
<HR><BR>
<CENTER>Registered PUB key List at ${NOW}</CENTER><BR><HR><BR>
<PRE>
EOF


echo "   KeyID   |                       fingerprint                  |   expire" >>/home/user/.gnupg/list.html
echo "-----------+----------------------------------------------------+------------" >>/home/user/.gnupg/list.html
gpg --list-key --fingerprint |ListKey.pl|sort >>/home/user/.gnupg/list.html


cat <<EOF >>/home/user/.gnupg/list.html
<BR>
<BR>
<!-- NINJA ANALYZE -->
<script type="text/javascript">
//<![CDATA[
(function(d) {
  var sc=d.createElement("script"),
      ins=d.getElementsByTagName("script")[0];
  sc.type="text/javascript";
  sc.src=("https:"==d.location.protocol?"https://":"http://") + "code.analysis.shinobi.jp" + "/ninja_ar/NewScript?id=00251129&hash=ecd2c33e&zone=36";
  sc.async=true;
  ins.parentNode.insertBefore(sc, ins);
})(document);
//]]>
</script>
<!-- /NINJA ANALYZE -->
</body>

</html>
EOF


#curl -s \
#        -T "/home/user/.gnupg/list.html" \
#        -u "crk.aikotoba.jp:c354aa66419c5d7c52595247305ba978" \
#        --retry 20 \
#        --retry-delay 10 \
#        --connect-timeout 300 \
#        ftp.homepage.shinobi.jp/  >/dev/null

cp /home/user/.gnupg/list.html /home/user/www/crk

exit 0;


