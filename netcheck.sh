#!/bin/bash
#
# netcheck.sh
#
# Copyright (C) 2010 "Sung-Ling Chen"  <tobala123@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/Licenses/>.
#
##########################################################################

#[ "$USER" != "root" ] && echo "需要 root 權限" && exit 1

# 安裝 fping 命令
. ./lib/inscmd.sh &>/dev/null

echo ""
echo "<html>"
echo -e "<head>\n<link rel=stylesheet type='text/css' href='netid.css'>\n</head>"
echo "<body>"

if [ "$#" -gt 0 ]; then
   nid="$@"
else
   [ ! -f "./conf/netid.conf" ] && echo "設定檔 (conf/netid.conf) 不存在" && exit 1
   nid=$(cat "./conf/netid.conf" | fmt -u)
fi

lip=$(ifconfig | grep -A1 'inet addr')

echo ""
for s in $nid
do
    echo -e "<div id='${s%/*}'>$s</div>\n<ol>"
    fping -c 1 -g -q $s &> "/tmp/${s%/*}.chk"
    nip=$(grep "min/avg/max" "/tmp/${s%/*}.chk" | cut -d' ' -f1 | fmt -u)

    for ip in $nip
    do
       # 本機不做檢查與複製, 以下檢查字串中的 B 之前有二個空白
       echo "$lip" | grep "inet addr:$ip  B" &>/dev/null 
       [ "$?" == "0" ] && echo "<li>$ip 跳過 (本機位址)" && continue

       echo -n "<li>$ip "

       nc -w 2 $ip 22 &>/dev/null
       [ "$?" == "0" ] && echo -n "ssh "

       nc -w 2 $ip 80 &>/dev/null
       [ "$?" == "0" ] && echo -n "www "

       nc -w 2 $ip 445 &>/dev/null
       [ "$?" == "0" ] && echo -n "smb"

       echo "" 
    done
    echo -e "</ol>\n"
done

echo -e "</body>\n</html>"

exit 0

