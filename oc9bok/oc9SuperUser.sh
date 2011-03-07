#!/bin/bash
#
# oc9SuperUser.sh
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
#######################################################################################

# 此程式必須是 root 執行
[ "$USER" != "root" ] && echo "權限不夠" && exit 1
[ -z "$1" ] && echo "請給設定檔" && exit 1
[ ! -f "$1" ] && echo "設定檔不存在" && exit 1 
clear

# 產生 Cloud_DIR, Cloud_USER 及 Cloud_CONNECT 這三個陣列變數
. ./lib/conf2env.sh $1

# 取得超級使用者資訊
oc9ip=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
atitle=$(echo "${Cloud_ADMIN[0]}" | cut -d ":" -f2)
adate=$(echo "${Cloud_ADMIN[1]}" | cut -d ":" -f2)
aname=$(echo "${Cloud_ADMIN[2]}" | cut -d ":" -f2)
alogin=$(echo "${Cloud_ADMIN[3]}" | cut -d ":" -f2)
apass=$(echo "${Cloud_ADMIN[4]}" | cut -d ":" -f2)
aemail=$(echo "${Cloud_ADMIN[5]}" | cut -d ":" -f2)
aDBIP=$(echo "${Cloud_DB[0]}" | cut -d ":" -f2)
aDBPort=$(echo "${Cloud_DB[1]}" | cut -d ":" -f2)


# 檢查是否已產生超級使用者帳號, 如有產生, 詢問是否刪除 ?
if [ -d "/home/$alogin" ]; then 
   echo -n "是否要刪除 $alogin 帳號 (y/n) ? "
   read -e Answer
   echo "" 
   [ "$Answer" != "y" ] && exit 0

   onlineuser=$(smbstatus -b | grep $alogin | fmt -u | cut -d ' ' -f2)
   
   if [ ! -z $onlineuser ]; then
      echo "$onlineuser 還在線上, 請離線後再執行此命令"
      exit 1
   fi

   # 一定要先刪除 Samba 使用者帳號, 才能刪除 Linux 使用者帳號
   pdbedit -w -L | awk -F: '{print $1}' | grep $alogin >/dev/null
   if [ $? == 0 ]; then
      /usr/bin/smbpasswd -x "$alogin" >/dev/null
      echo "刪除 $alogin (Samba) 使用者帳號成功 "
   fi 

   ./lib/usermanager.sh -d "$alogin"

   echo ""
   exit 0
fi

# 詢問是否要建立超級使用者帳號 ?
echo -n "是否要建立 $alogin 帳號 (y/n) ? "
read -e Answer
echo "" 
[ "$Answer" != "y" ] && exit 0

# 建立超級使用者密碼
pass=$(perl -e 'print crypt($ARGV[0], "password")' "$apass")

# 建立超級使用者帳號
useradd -m -s /bin/bash -p $pass "$alogin" &>/dev/null
[ $? == 0 ] && echo "$alogin 使用者帳號建立成功" 

# 建立超級使用者 Samba 帳號
(echo "$apass";echo "$apass") | /usr/bin/smbpasswd -as "$alogin" >/dev/null
echo "新增 $alogin (Samba) 使用者帳號成功" 

# 建立超級使用者應用目錄
cd /home/$alogin
index=0; awww=""; asys=""; atest=""
while [ "${Cloud_DIR[$index]}" != "end" ]
do
  adir=$(echo "${Cloud_DIR[$index]}" | cut -d ":" -f1)
  atype=$(echo "${Cloud_DIR[$index]}" | cut -d ":" -f2)

  case  "$atype" in
     3)
      awww="$adir"
       ;;
     2)
      asys="$adir"
       ;;
     1)
      atest="$adir"
      mkdir ./"$adir"
      
      c=0
      while [ "${Cloud_Test[$c]}" != "end" ]
      do
         mkdir ./"$adir"/"${Cloud_Test[$c]}"
         let "c=$c+1"
      done

      chown -R "$alogin:$alogin" ./"$adir"
      echo "./$adir 建立成功"
       ;;
  esac
  [ ! -d ./"$adir" ] && mkdir ./"$adir" && chown -R "$alogin:$alogin" ./"$adir" && echo "./$adir 建立成功"
     
  let "index=$index+1"
done

# 建立超級使用者的網站虛擬目錄
if [ -d /var/www/ ]; then 

   if [ -d "/home/$alogin/$awww" ]; then
      [ -L /var/www/$alogin ] && rm /var/www/$alogin &>/dev/null
      ln -s "/home/$alogin/$awww" "/var/www/$alogin" &>/dev/null
      [ $? == 0 ] && echo "$alogin 豆知識筆記本網站建立成功 ($awww)"
   fi

   if [ -d "/home/$alogin/$atest" ]; then
      [ -L /var/www/$atest ] && rm /var/www/$atest &>/dev/null
      ln -s "/home/$alogin/$atest" "/var/www/$atest" &>/dev/null
      [ $? == 0 ] && echo "$alogin 評量網站建立成功 ($atest)"
   fi
fi
echo ""

echo "產生 $alogin 的 oc9info.txt 檔案"
echo "[" > /home/$alogin/$asys/oc9info.txt
echo "'User:$alogin'," >> /home/$alogin/$asys/oc9info.txt
echo "'Name:$aname'," >> /home/$alogin/$asys/oc9info.txt
echo "'OC9IP:$oc9ip'," >> /home/$alogin/$asys/oc9info.txt
echo "'DBIP:$aDBIP'," >> /home/$alogin/$asys/oc9info.txt
echo "'DBPort:$aDBPort'," >> /home/$alogin/$asys/oc9info.txt
echo "'ExamDIR:$atest'," >> /home/$alogin/$asys/oc9info.txt
echo "]" >> /home/$alogin/$asys/oc9info.txt

# 建立使用者清單
echo > /home/$alogin/$asys/users

index=0
while [ "${Cloud_USER[$index]}" != "end" ]
do
   user=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f1)
   name=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f3)
   email=$(echo "${Cloud_USER[$index]}" | cut -d ":" -f4)

   echo "$user:$name:$email" >> /home/$alogin/$asys/users

   let "index=$index+1"
done 








