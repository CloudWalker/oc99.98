#!/bin/bash
#
# oc9User.sh
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
##################################################################################

# 此程式必須是 root 執行
[ "$USER" != "root" ] && echo "權限不夠" && exit 1

[ -z "$1" ] && echo "請給參數 (-c or -d) 設定檔" && exit 1

# 檢查設定檔參數
[ -z "$2" ] && echo "請給設定檔" && exit 1
[ ! -f "$2" ] && echo "設定檔不存在" && exit 1 

# 產生 Cloud_DIR, Cloud_USER 及 Cloud_CONNECT 這三個陣列變數
. ./lib/conf2env.sh $2

# 檢查是否有使用者連線
index=0
while [ "${Cloud_USER[$index]}" != "end" ]
do
   user=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f1)
   onlineuser=$(smbstatus -b | grep $user | fmt -u | cut -d ' ' -f2)
   
   if [ ! -z $onlineuser ]; then
      echo "$onlineuser 還在線上, 請離線後再執行此命令"
      exit 1
   fi

   let "index=$index+1"
done 

# 產生 oc9info.txt 檔案
oc9ip=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
alogin=$(echo "${Cloud_ADMIN[3]}" | cut -d ":" -f2)
aDBIP=$(echo "${Cloud_DB[0]}" | cut -d ":" -f2)
aDBPort=$(echo "${Cloud_DB[1]}" | cut -d ":" -f2)
scjp=$(echo "${Cloud_Test[0]}" | cut -d ":" -f2)
lpic=$(echo "${Cloud_Test[1]}" | cut -d ":" -f2)

case  "$1" in
     -c)

         echo -n "確定要建立全部帳號 (y/n) ? "
         read -e Answer
         echo "" 
         [ "$Answer" != "y" ] && exit 0

         # 建立 /etc/skel 的 oncloud9 目錄
         index=0; asys=""; atest=""
         while [ "${Cloud_DIR[$index]}" != "end" ]
         do
           adir=$(echo "${Cloud_DIR[$index]}" | cut -d ":" -f1)
           [ ! -d /etc/skel/"$adir" ] && mkdir /etc/skel/"$adir" && echo "/etc/skel/$adir 建立成功"

           atype=$(echo "${Cloud_DIR[$index]}" | cut -d ":" -f2)
           [ "$atype" == "2" ] && asys="$adir"
           [ "$atype" == "1" ] && atest="$adir"

           let "index=$index+1"
         done
         echo ""

         # 建立使用者帳號
         index=0
         while [ "${Cloud_USER[$index]}" != "end" ]
         do
           user=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f1)
           pass=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f2) 
           uname=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f3)

           ./lib/usermanager.sh -c "$user" "$pass" "$uname"
           
           # 檢查是否已存在 Samba 使用者帳號
           pdbedit -w -L | awk -F: '{print $1}' | grep $user >/dev/null 
           if [ $? != 0 ]; then
              # 新增 Samba 使用者帳號
              (echo "$pass";echo "$pass") | /usr/bin/smbpasswd -as "$user" >/dev/null
              echo "新增 $user (Samba) 使用者帳號成功"  
           fi 

           [ ! -d /home/$user/$asys ] && echo "$user 沒有 $asys 目錄" && let "index=$index+1" && continue

           echo "產生 $user 的 oc9info.txt 檔案"
           echo "[" > /home/$user/$asys/oc9info.txt
           echo "'User:$user'," >> /home/$user/$asys/oc9info.txt
           echo "'Name:$uname'," >> /home/$user/$asys/oc9info.txt
           echo "'OC9IP:$oc9ip'," >> /home/$user/$asys/oc9info.txt
           echo "'DBIP:$aDBIP'," >> /home/$user/$asys/oc9info.txt
           echo "'DBPort:$aDBPort'," >> /home/$user/$asys/oc9info.txt
           echo "'ExamDIR:$atest'," >> /home/$user/$asys/oc9info.txt
           echo "]" >> /home/$user/$asys/oc9info.txt

             # 將 oc9info.txt 設成唯讀
           chmod -w /home/$user/$asys/oc9info.txt &>/dev/null

           let "index=$index+1"
           echo ""
         done
         exit 0
         ;;
     -d)

         echo -n "確定要全部刪除 (y/n) ? "
         read -e Answer
         echo "" 
         [ "$Answer" != "y" ] && exit 0

         # 刪除 /etc/skel 的 oncloud9 目錄
         index=0
         while [ "${Cloud_DIR[$index]}" != "end" ]
         do
           adir=$(echo "${Cloud_DIR[$index]}" | cut -d ":" -f1)
           [ -d /etc/skel/"$adir" ] && rm -r /etc/skel/"$adir" && echo "/etc/skel/$adir 刪除成功"
           let "index=$index+1"
         done
         echo ""
 
         # 刪除使用者帳號
         index=0
         while [ "${Cloud_USER[$index]}" != "end" ]
         do
           user=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f1)

           # 一定要先刪除 Samba 使用者帳號, 才能刪除 Linux 使用者帳號
           pdbedit -w -L | awk -F: '{print $1}' | grep $user >/dev/null
           if [ $? == 0 ]; then
              /usr/bin/smbpasswd -x "$user" >/dev/null
              echo "刪除 $user (Samba) 使用者帳號成功 "
           fi 

           ./lib/usermanager.sh -d "$user"

           let "index=$index+1"
           echo ""
         done
         exit 0
         ;;
      *)
         echo "參數無法處理"
         ;;
esac

