#!/bin/bash
#
# conf2env.sh
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
[ "$USER" != "root" ] && echo "權限不夠" && exit 1

[ ! -f $1 ] && echo "請給設定檔" && exit 1

# 自動安裝 libxml-xpath-perl 套件, 安裝後才可執行 xpath 命令
if [ ! -f  /usr/bin/xpath ]; then
   echo "請稍後 libxml-xpath-perl 套件正安裝中"
   apt-get -y install libxml-xpath-perl &>/dev/null
   [ "$?" != "0" ] && echo "xpath error" && exit 1
fi

declare -a Cloud_ADMIN
declare -a Cloud_DIR
declare -a Cloud_USER
declare -a Cloud_DB
declare -a Cloud_Test

# oncloud9.conf 這設定檔如有中文字, xpath 命令處理會,
# 出現 "Wide character in print at /usr/bin/xpath line 93" 訊息

# 建立管理者資訊陣列
CloudADMIN=$(xpath -q -e "//CloudAdmin/text()" $1 2>/dev/null | sed '/^$/d' | tr -d ' ')
index=0
for x in $CloudADMIN
do
     # echo "$x"
     Cloud_ADMIN[$index]="$x"
     let "index=$index+1"
done
Cloud_ADMIN[$index]="end"

# 建立應用目錄資訊陣列
CloudDir=$(xpath -q -e "//CloudDir/text()" $1 2>/dev/null | sed '/^$/d' | tr -d ' ')
index=0
for x in $CloudDir
do
     # echo "$x"
     Cloud_DIR[$index]="$x"
     let "index=$index+1"
done
Cloud_DIR[$index]="end"

# 建立使用者資訊陣列
CloudUser=$(xpath -q -e "//CloudUser/text()" $1 2>/dev/null| sed '/^$/d' | tr -d ' ')
index=0
for x in $CloudUser
do
     # echo "$x"
     Cloud_USER[$index]="$x"
     let "index=$index+1"
done
Cloud_USER[$index]="end"

# 建立雲端伺服器資訊陣列
CloudDB=$(xpath -q -e "//CloudDB/text()" $1 2>/dev/null| sed '/^$/d' | tr -d ' ')
index=0
for x in $CloudDB
do
     # echo "$x"
     Cloud_DB[$index]="$x"
     let "index=$index+1"
done
Cloud_DB[$index]="end"

# 建立評量資訊陣列
CloudTest=$(xpath -q -e "//CloudTest/text()" $1 2>/dev/null| sed '/^$/d' | tr -d ' ')
index=0
for x in $CloudTest
do
     # echo "$x"
     Cloud_Test[$index]="$x"
     let "index=$index+1"
done
Cloud_Test[$index]="end"


