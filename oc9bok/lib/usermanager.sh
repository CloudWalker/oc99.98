#!/bin/bash
#
# usermanager.sh
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

[ -z $1 ] && echo "請給參數 (-c or -d)" && exit 1
[ -z $2 ] && echo "請給使用者帳號名稱" && exit 1

# 不論誰呼叫此程式, 下式確定此程式會在自己的目錄中執行
#c=$(dirname $0)
cd `dirname $0`        # ` 這字元是在 ~ 這按鍵中, 請用心看

case  "$1" in
     -c)
         # 檢查是否已產生帳號
         [ -d "/home/$2" ] && echo "$2 帳號已產生" && exit 1

         [ -z $3 ] && echo "請給使用者帳號密碼" && exit 1

         # 設定密碼
         pass=$(perl -e 'print crypt($ARGV[0], "password")' "$3")

         # 建立使用者帳號
         useradd -m -s /bin/bash -p $pass "$2" &>/dev/null
         [ $? == 0 ] && echo "$2 使用者帳號建立成功" 

         # 建立簡易虛擬目錄名稱
        # if [ -d /var/www/  ]; then 
        #   if [ -d "/home/$2/豆知識網站" ]; then
        #      ln -s "/home/$2/豆知識網站" "/var/www/$2" &>/dev/null
        #      [ $? == 0 ] && echo "$2 使用者個人網站建立成功"
        #      ./mkindex.sh "/home/$2/豆知識網站" "$4 ($2)"
        #   fi
        # fi
         ;;
     -d)
         # 刪除使用者帳號
         userdel -r "$2" &>/dev/null 
         [ $? == 0 ] && echo "$2 使用者帳號刪除成功" 
         #[ -d /var/www/ ] && rm "/var/www/$2" &>/dev/null
         #[ $? == 0 ] && echo "$2 使用者個人網站刪除成功"
         ;;
esac
