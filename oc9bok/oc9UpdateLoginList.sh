#!/bin/bash
#
# oc9UpdateLoginList.sh
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
[ -z $1 ] && echo "請給重整時間" && exit 1
[ -z "$2" ] && echo "請給設定檔" && exit 1
[ ! -f "$2" ] && echo "設定檔不存在" && exit 1 

old_tty_setting=$(stty -g)      # Save old terminal settings
stty -icanon -echo time 2 min 0 # Disable canonical mode and echo

clear
before="$(date +%s)"
echo -ne "\033[0;0f每 $1 分鐘, 重整一次登入清單, 按 'Q' 或 'q' 停止重整"
times=1
while [ 1 ] 
do
  after="$(date +%s)"
  elapsed_minute=$(( ( $after - $before ) / 60 ))

  if [ $elapsed_minute -ge $1 ]; then
     before="$(date +%s)"
     t=$(date +%H:%M)
     # 清除螢幕第二行資料
     echo -ne "\033[2;0f                                                            "

     ./lib/mkloginlist.sh $2
     if [ $? == 1 ]; then
         echo -ne "\033[2;0f$t 重整第 $times 次, 沒人在線上"
     else 
         echo -ne "\033[2;0f$t 重整第 $times 次"
     fi 

     let "times=$times+1"
  fi

  keys=$(dd bs=1 count=1 2>/dev/null)
  ( [ "$keys" == "q" ] || [ "$keys" == "Q" ] ) && echo "" && break

done

stty "$old_tty_setting"     # Restore old terminal settings
