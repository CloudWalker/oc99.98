#!/bin/bash
#
# oc9bok.sh
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

# 此程式必須是 root 執行
[ "$USER" != "root" ] && echo "需要 root 權限" && exit 1

# 安裝 Apache 與 Samba
./oc9prep.sh 
[ "$?" != 0 ] && echo "請手動安裝 Apache2 及 Samba 伺服器" && exit 1

# 檢查設定檔參數
if [ -z "$1" ]; then 
   oc9conf="conf/oc9.conf"
else
   oc9conf="$1"
fi

[ ! -f "$oc9conf" ] && echo "設定檔不存在" && exit 1 

# 取得設定檔完整目錄
oc9conf=$(readlink -f $oc9conf)

# 產生 Cloud_ADMIN, Cloud_DIR, Cloud_USER 及 Cloud_CONNECT 陣列變數
. ./lib/conf2env.sh $oc9conf

# 取得 TCP/IP 資訊
ip=$(ifconfig  | grep -A1 'eth0')
ip=$(echo $ip | cut -d' ' -f7)
ip=${ip##*:}
ga=$(route -n | grep ^0.0.0.0 | fmt -u | cut -d ' ' -f2)
dns=$(cat /etc/resolv.conf | grep 'nameserver' | fmt -u | cut -d ' ' -f2)

alogin=$(echo "${Cloud_ADMIN[3]}" | cut -d ":" -f2)
clear
# echo "${Cloud_ADMIN[@]}";read

function outputMenu {
echo ""
echo "====================== on cloud 9 雲端系統 (V 0.2) ======================="
echo -n " 超級使用者資訊 "
if [ ! -d /home/$alogin ]; then
   echo "(帳號未產生)"
else
   echo -e "\n   帳號 : $alogin" 
   echo "   網路磁碟機 : \\\\$ip\\$alogin"
   echo "   網址 : http://$ip/$alogin"
fi
echo ""
echo " 本機資訊"
echo "   IP 位址 : $ip"
echo "   Gateway 位址 : $ga"
echo "   DNS 位址 : $dns"
echo "=========================================================================="
echo "[1] 批次建立使用者帳號"
echo "[2] 批次刪除使用者帳號"
echo "[3] 批次更新使用者家目錄 (/home) 資料"
echo "[4] 更新使用者登入清單 (Samba)"
echo "[5] 學習評量"
echo "[6] 建立與刪除超級使用者帳號 ($alogin)"
echo "[7] 編輯設定檔 ($oc9conf)"
echo "[8] 離開"

echo ""
echo -ne "輸入代號, 執行所需的功能 : "
read USERCHOICE
clear

case $USERCHOICE in
        "1") 
            [ ! -d /home/$alogin ] && echo "請先建立超級使用者帳號" && return
            ./oc9User.sh -c $oc9conf;;

        "2") 
            [ ! -d /home/$alogin ] && echo "請先建立超級使用者帳號" && return
            ./oc9User.sh -d $oc9conf;;
        "3") 
            [ ! -d /home/$alogin ] && echo "請先建立超級使用者帳號" && return
            ./oc9UpdateDir.sh $oc9conf;;
        "4") 
            [ ! -d /home/$alogin ] && echo "請先建立超級使用者帳號" && return
            echo -n "請輸入間隔時間 : "
            read -e inter
            [ -z "$inter" ] && return
            echo "" 
            [ "$inter" -gt "0" ] && ./oc9UpdateLoginList.sh $inter $oc9conf
            ;;
        "5") 
            [ ! -d /home/$alogin ] && echo "請先建立超級使用者帳號" && return

            echo -n "請輸入考試時間 (30-240) : "
            read -e no
            [ -z "$t" ] && return
            echo "" 

            echo -n "請輸入題庫目錄名稱 : "
            read -e name
            [ -z "$name" ] && return
            echo "" 

            ./oc9TestSystem.sh $t $name $oc9conf
            ;;
        "6") ./oc9SuperUser.sh $oc9conf;;
        "7") 
            [ -d /home/$alogin ] && echo "請先移除超級使用者帳號及所有帳號" && return
            nano $oc9conf;;
        "8") 
            echo -n "確定離開 (y/n) ? "
            read -e ans
            [ "$ans" == "y" ] && exit 0
            echo "" 
            ;;
        *) echo "無法處理 $USERCHOICE";;
esac
}
 
while [ 1 ]; do
   clear
 
   outputMenu
   
   echo ""
   echo -ne "按任何鍵, 回到主選單... "
   read
done
