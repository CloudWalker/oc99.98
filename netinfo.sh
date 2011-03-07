#!/bin/bash
#
# netinfo.sh
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

[ "$USER" != "root" ] && echo "需要 root 權限" && exit 1

if [ "$#" -gt 0 ]; then
   nid="$1"
else
   [ ! -f "./conf/netid.conf" ] && echo "設定檔不存在" && exit 1
   nid=$(cat "./conf/netid.conf" | fmt -u)
fi

# 清除 $HOME/.ssh 目錄中的憑證檔
if [ -f $HOME/.ssh/known_hosts ]; then 
   rm $HOME/.ssh/known_hosts  &>/dev/null
   [ "$?" != "0" ] && echo ".ssh/known_hosts 刪除失敗" && exit 1 
fi

# 安裝命令 (fping, tree, expect)
. ./lib/inscmd.sh

[ -z "$2" ] && lg="student" || lg="$2"
[ -z "$3" ] && pa="student" || pa="$3"

echo ""
for s in $nid
do
    echo "收集以下主機的網路設定資訊 : $s "
    echo "------------------------------------------------"
    fping -c 1 -g -q $s &> "/tmp/${s%/*}.chk"
    nip=$(grep "min/avg/max" "/tmp/${s%/*}.chk" | cut -d' ' -f1 | fmt -u)
    
    [ -d ./html ] && rm ./html/* &>/dev/null

    for ip in $nip
    do
       nc -w 2 $ip 22 &>/dev/null
       if [ "$?" == "0" ]; then
          ./lib/autossh.sh $ip $lg $pa 'cat /etc/network/interfaces' &> /tmp/netchk.txt

          grep "Permission denied" /tmp/netchk.txt &>/dev/null
          if [ "$?" != "0" ];then

             # 取得 IP 設定
             echo -e "<h1>$ip</h1>\n<b>IP 設定</b>\n<pre>" > ./html/$ip.html
             cat /tmp/netchk.txt | sed -n '/cat \/etc/,/exit/p' | grep -v "$lg@" >> ./html/$ip.html
             echo -e "\n</pre>" >> ./html/$ip.html

             # 取得路由表  
             echo -e "\n<b>路由表</b>\n<pre>" >> ./html/$ip.html
             ./lib/autossh.sh $ip $lg $pa 'route -n' &> /tmp/netchk.txt
             cat /tmp/netchk.txt | sed -n '/route -n/,/exit/p' | grep -v "$lg@" >> ./html/$ip.html
             echo -e "</pre>" >> ./html/$ip.html

             # 取得 DNS   
             echo -e "\n<b>DNS</b>\n<pre>" >> ./html/$ip.html
             ./lib/autossh.sh $ip $lg $pa 'cat /etc/resolv.conf' &> /tmp/netchk.txt
             cat /tmp/netchk.txt | sed -n '/cat \/etc/,/exit/p' | grep -v "$lg@" >> ./html/$ip.html
             echo -e "</pre>" >> ./html/$ip.html

             echo "$ip ($ip.html)"
          fi 

       fi
    done
    echo ""
done

exit 0

