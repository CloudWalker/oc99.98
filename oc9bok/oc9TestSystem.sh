#!/bin/bash
#
# oc9TestSystem.sh
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
#########################################################################################

# 此程式必須由 root 執行
c=$(whoami)
[ "$c" != "root" ] && echo "權限不夠" && exit 1

# 檢查參數與目錄
( ([ -z "$1" ] || [ -z "$2" ]) || [ $1 -lt 30 ] ) && echo "語法 : oc9TestSystem.sh '考試時間 (30 ~ 240 分鐘)' '題庫目錄名稱'" && exit 1

# 檢查設定檔參數
[ -z "$3" ] && echo "請給設定檔" && exit 1
[ ! -f "$3" ] && echo "設定檔不存在" && exit 1 

# 產生 Cloud_USER 陣列變數
. ./lib/conf2env.sh $3

index=0; atest=""
while [ "${Cloud_DIR[$index]}" != "end" ]
do
  adir=$(echo "${Cloud_DIR[$index]}" | cut -d ":" -f1)
  atype=$(echo "${Cloud_DIR[$index]}" | cut -d ":" -f2)

  [ "$atype" == "1" ] && atest="$adir"

  let "index=$index+1"
done


# 檢查題庫目錄是否存在 ?
alogin=$(echo "${Cloud_ADMIN[3]}" | cut -d ":" -f2)
[ ! -d "/home/$alogin/$atest/$2" ] && echo "題庫目錄不存在 : $2 " && exit 1

# 複製考題
index=0
while [ "${Cloud_USER[$index]}" != "end" ]
do
   user=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f1)
   if [ ! -d "/home/$user/$atest/$2" ]; then
      mkdir "/home/$user/$atest/$2" 
      mount --bind "/home/$alogin/$atest/$2" "/home/$user/$atest/$2"
   fi
   let "index=$index+1"
done 

# 檢查是否已出題
if [ -f ./start.time ]; then
   echo -n "是否要重新考試 (y/n) ? "
   read -e Answer
   echo "" 
   if [ "$Answer" == "y" ];then
      before="$(date +%s)"
      echo "$before" > ./start.time
   else
      em=$(cat ./start.time)
      before=$em
   fi
else
   before="$(date +%s)"
   echo "$before" > ./start.time
fi

# 等待收卷
clear
old_tty_setting=$(stty -g)      # Save old terminal settings
stty -icanon -echo time 2 min 0 # Disable canonical mode and echo

echo "$2 開始測試, 測試時間為 $1 分, 按 'Q' 或 'q' 停止考試" 
echo ""
elapsed_minute=0
test_minute=$1
while [ $elapsed_minute -lt $test_minute ]
do
  after="$(date +%s)"
  elapsed_minute=$(( ( $after - $before ) / 60 ))
  test_remain=$(( $test_minute - $elapsed_minute ))
  echo -ne "\033[2;0f考試時間剩餘 : $test_remain 分"

  keys=$(dd bs=1 count=1 2>/dev/null)
  ( [ "$keys" == "q" ] || [ "$keys" == "Q" ] ) && echo "" && break
done
stty "$old_tty_setting"     # Restore old terminal settings
echo ""

# 開始收卷
index=0
while [ "${Cloud_USER[$index]}" != "end" ]
do
   user=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f1)

   [ -d "/home/$user/$atest/$2" ] && umount "/home/$user/$atest/$2" && rm -R "/home/$user/$atest/$2"

   let "index=$index+1"
done 
rm ./start.time


