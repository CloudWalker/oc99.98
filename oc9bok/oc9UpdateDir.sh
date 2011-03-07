#!/bin/bash
#
# oc9UpdateDir.sh
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
c=$(whoami)
[ "$c" != "root" ] && echo "權限不夠" && exit 1

# 檢查設定檔參數
[ -z "$1" ] && echo "請給設定檔" && exit 1
[ ! -f "$1" ] && echo "設定檔不存在" && exit 1 

# 產生 Cloud_DIR, Cloud_USER 及 Cloud_CONNECT 這三個陣列變數
. ./lib/conf2env.sh $1

# 檢查第一個使用者存不存在
user=$(echo "${Cloud_USER[0]}" | cut -d ":" -f1)
[ ! -d /home/$user ] && echo "使用者不存在" && exit 1

echo -n "複製新資料至所有使用者的家目錄 (y/n) ? "
read -e Answer
echo "" 
[ "$Answer" != "y" ] && exit 0

index=0; asys=""
while [ "${Cloud_DIR[$index]}" != "end" ]
do
  adir=$(echo "${Cloud_DIR[$index]}" | cut -d ":" -f1)
  atype=$(echo "${Cloud_DIR[$index]}" | cut -d ":" -f2)

  [ "$atype" == "2" ] && asys="$adir"

  let "index=$index+1"
done

index=0
while [ "${Cloud_USER[$index]}" != "end" ]
do
   user=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f1)
   name=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f3)

   # 更新所有指定目錄
   echo "開始更新 $user 的目錄"

   # 記錄更新內容
   cpdate=$(date +%Y_%m_%d_%H_%M)
   echo "" > /home/$user/$asys/"$cpdate"_copy.log

   dirindex=0
   while [ "${Cloud_DIR[$dirindex]}" != "end" ]
   do
     dirN=$(echo "${Cloud_DIR[$dirindex]}" | cut -d ":" -f1)
     dirA=$(echo "${Cloud_DIR[$dirindex]}" | cut -d ":" -f2)
     
     if [ "$dirA" == "0" ]; then
        if [ -d /home/$alogin/$dirN ]; then
           echo -n "---$dirN (" 
           
           # -u 更新時間較新或檔案不存在才進行動作
           # -v 顯示複製資訊
           cp -vuRp "/home/$alogin/$dirN" "/home/$user/" > /home/$user/$asys/temp_copy.log
           fline=$(wc -l /home/$user/$asys/temp_copy.log | cut -d ' ' -f1)
           echo "共更新 $fline 檔案)"
           cat /home/$user/$asys/temp_copy.log >> /home/$user/$asys/"$cpdate"_copy.log

           chown -R "$user:$user" "/home/$user/$dirN"
        fi
     fi 
     let "dirindex=$dirindex+1"
   done
   rm /home/$user/$asys/temp_copy.log

   echo ""
   let "index=$index+1"
done

