#!/bin/bash
#
# mkloginlist.sh
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

# 此程式必須由 root 執行
c=$(whoami)
[ "$c" != "root" ] && echo "權限不夠" && exit 1

# 檢查執行參數
[ -z "$1" ] && echo "請給設定檔" && exit 1
[ ! -f "$1" ] && echo "設定檔不存在" && exit 1 

# 不論誰呼叫此程式, 下式確定此程式會在自己的目錄中執行
#c=$(dirname $0)
cd `dirname $0`        # ` 這字元是在 ~ 這按鍵中, 請用心看

# 產生 Cloud_USER 陣列變數
. ./conf2env.sh $1

# 產生連接使用者名單
echo "[" > ./oc9Loginlist.txt
index=0
somebody=0
while [ "${Cloud_USER[$index]}" != "end" ]
do
   user=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f1)

   onlineuser=$(smbstatus -b | grep $user | fmt -u | cut -d ' ' -f2)

   if [ ! -z $onlineuser ]; then
      userip=$(smbstatus -b | grep $user | fmt -u | cut -d ' ' -f5 | tr -d ')' | cut -d ':' -f4)
      echo "[ '$onlineuser','$userip' ]," >> ./oc9Loginlist.txt
      somebody=1
   fi

   [ -f /home/$user/oc99.9/oc9Loginlist.txt ] && rm /home/$user/oc99.9/oc9Loginlist.txt

   let "index=$index+1"
done 
echo "]" >> ./oc9Loginlist.txt

# 沒人連線停止執行
[ $somebody == 0 ] && rm ./oc9Loginlist.txt && exit 1

# 複製登入名單
index=0
while [ "${Cloud_USER[$index]}" != "end" ]
do
   user=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f1)
   if [ -d /home/$user/oc99.9 ]; then
      cp ./oc9Loginlist.txt /home/$user/oc99.9
      chmod -w /home/$user/oc99.9/oc9Loginlist.txt &>/dev/null
   fi
   let "index=$index+1"
done 
rm ./oc9Loginlist.txt


