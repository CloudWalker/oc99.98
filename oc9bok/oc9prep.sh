#!/bin/bash
#
# oc9prep.sh
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

clear
s=0
[ "$USER" != "root" ] && echo "需要 root 權限" && s=1
[ ! -f ./conf/httpd.conf ] && echo "Apache 設定檔找不到" && s=1
ping -c 2 168.95.1.1 &>/dev/null
[ "$?" != "0" ] && echo "外網不通 (168.95.1.1)" && s=1

[ "$s" == "1" ] && echo "請按任何鍵..." && exit 1

# 
# 建置 Apache 2 伺服系統
#
which apache2 &>/dev/null
if [ "$?" != "0" ]; then
   echo -n "確定要安裝 Apache2 伺服器 (y/n) : "
   read -e ans
 
   if [ "$ans" == "y" ]; then

      apt-get -y --force-yes install apache2 &>/dev/null
      [ "$?" != "0" ] && echo "Apache2 伺服器安裝失敗" && exit 1
      echo "Apache2 伺服器安裝成功"

      a2enmod userdir &>/dev/null
      [ "$?" != "0" ] && echo "家目錄模組安裝失敗" && exit 1
      echo "家目錄模組安裝成功"

      cp ./conf/httpd.conf /etc/apache2/httpd.conf &>/dev/null
      [ "$?" != "0" ] && echo "設定檔 (/etc/apache2/httpd.conf) 複製失敗" && exit 1
      echo "設定檔 (/etc/apache2/httpd.conf) 複製成功"

      /etc/init.d/apache2 restart &>/dev/null
      [ "$?" != "0" ] && echo "Apache2 伺服器重新啟動失敗" && exit 1
      echo "Apache2 伺服器重新啟動成功"
   else
      exit 1
   fi
fi

echo ""

# 
# 建置 Samba 伺服系統
#
which smbd &>/dev/null
if [ "$?" != "0" ]; then
   echo -n "確定要安裝 Samba 伺服器 (y/n) : "
   read -e ans
 
   if [ "$ans" == "y" ]; then

      apt-get -y --force-yes install samba &>/dev/null
      [ "$?" != "0" ] && echo "Samba 伺服器安裝失敗" && exit 1
      echo "Samba 伺服器安裝成功"

      cp ./conf/smb.conf /etc/samba/smb.conf &>/dev/null
      [ "$?" != "0" ] && echo "設定檔 (/etc/samba/smb.conf) 複製失敗" && exit 1
      echo "設定檔 (/etc/samba/smb.conf) 複製成功"

      apt-get -y install libpam-smbpass &>/dev/null
      [ "$?" != "0" ] && echo "帳號同步模組安裝失敗" && exit 1
      echo "帳號同步模組安裝成功"

      restart smbd &>/dev/null
      [ "$?" != "0" ] && echo "Samba 伺服器重新啟動失敗" && exit 1
      echo "Samba 伺服器重新啟動成功"
   else
      exit 1
   fi
fi

exit 0


