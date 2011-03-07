#!/bin/bash
#
# cprep.sh
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

# 安裝 fping, tree, expect 命令
. ./lib/inscmd.sh

[ -z "$2" ] && lg="student" || lg="$2"
[ -z "$3" ] && pa="student" || pa="$3"

lip=$(ifconfig | grep 'inet addr')

echo ""
for s in $nid
do
    echo "$s "
    echo "--------------------------"
    fping -c 1 -g -q $s &> "/tmp/${s%/*}.chk"
    nip=$(grep "min/avg/max" "/tmp/${s%/*}.chk" | cut -d' ' -f1 | fmt -u)
    
    for ip in $nip
    do
       # 本機不做檢查與複製, 以下檢查字串中的 B 之前有二個空白
       echo "$lip" | grep "inet addr:$ip  B" &>/dev/null 
       [ "$?" == "0" ] && echo "$ip 跳過 (本機位址)" && continue

       nc -w 2 $ip 22 &>/dev/null
       if [ "$?" == "0" ]; then
          ./lib/autoscp.sh $ip $lg $pa ./oc9prep /home/$lg &>/tmp/$ip.scp
          grep "Permission denied" /tmp/$ip.scp &>/dev/null
          [ "$?" != "0" ] && echo "$ip 複製成功" || echo "$ip 複製失敗"
       else
          echo "$ip 沒有安裝 OpenSSH"
       fi
    done
    echo ""
done

exit 0

