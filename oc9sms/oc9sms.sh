#!/bin/bash
#
# oc9sms.sh
#
# Copyright (C) 2010 "Sung-Ling Chen"  <oc99.98@gmail.com>
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
########################################################################################

# 此程式必須是 root 執行
[ "$USER" != "root" ] && echo "需要 root 權限" && exit 1

# 取得本機 IP 位址
ip=$(ifconfig  | grep -A1 'eth0')
ip=$(echo $ip | cut -d' ' -f7)
ip=${ip##*:}

# 取得 KVM 主機 IP 位址 
if [ -z "$ip" ]; then
   ip=$(ifconfig  | grep -A1 'br0')
   ip=$(echo $ip | cut -d' ' -f7)
   ip=${ip##*:}
fi

# 取得本機 Gateway 位址
ga=$(route -n | grep ^0.0.0.0 | fmt -u | cut -d ' ' -f2)

# 取得本機 DNS 位址
dns=$(cat /etc/resolv.conf | grep 'nameserver' | fmt -u | cut -d ' ' -f2)

BACKTITLE="OC9 本機網路管理系統 V0.1"
TEMPFILE=/tmp/dialogselect

while [ 1 ]; do

  dialog --clear --ascii-lines --title "主選單" \
       --backtitle "$BACKTITLE" \
       --no-cancel --ok-label "ok" --menu "本機網路設定\n IP 位址 : $ip\n Gateway 位址 : $ga\n DNS 位址 : $dns" \
       14 45 10 \
       1. "設定 IP 位址" \
       2. "設定 Gateway 位址" \
       3. "設定 DNS 位址" \
       4. "離開" 2> $TEMPFILE

  choice=`cat $TEMPFILE`

  case $choice in
        "1.") 
             clear
             ./lib/chgip.sh;;
        "2.")
             clear 
             ./lib/chggw.sh;;
        "3.")
             clear 
             ./lib/chgdns.sh;;
        "4.") 
            clear
            exit 0
            ;;
        *) echo "無法處理 $choice";;
  esac
done


