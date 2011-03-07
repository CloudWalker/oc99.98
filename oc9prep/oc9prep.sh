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

[ "$USER" != "root" ] && echo "需要 root 權限" && exit 1
[ ! -f ./conf/bashrc ] && echo "設定檔案 (conf/bashrc) 找不到" && exit 1

# 安裝套件 (tree, fping,...)
./lib/inscmd.sh
[ "$?" != "0" ] && echo "無法安裝套件" && exit 1

# 檢查是否為 Desktop 版本, 如為 Desktop 版本 xw 設定為 1
[ -n "$DISPLAY" ] && xw=1 || xw=0

# logout flag
rlflag='0'
# reboot flag
rbflag='0'

echo "本機設定項目如下 :"
echo "-------------------------------------------"
c=1

# 增加 .bashrc 程式內容 
grep '# add by bobe' "$HOME/.bashrc" &>/dev/null
if [ "$?" != "0" ] && [ "$xw" != "1" ]; then
   locale-gen en_US.UTF-8 &>/dev/null
   [ "$?" == "0" ] && echo "$c. 英文語系 (en_US) 安裝完成"
   c=$(( c + 1 ))

   cat "./conf/bashrc" >> "$HOME/.bashrc"
   [ "$?" == "0" ] && echo "$c. 登入程式 (~/.bashrc) 擴充完成"
   c=$(( c + 1 ))
   rlflag=1
fi

# 增加 Serial Console 
if [ ! -f /etc/init/ttyS0.conf ]; then
   cp "./conf/ttyS0.conf" /etc/init/
   [ "$?" == "0" ] && echo "$c. 增加序列控制介面 (ttyS0.conf) 完成"
   c=$(( c + 1 ))
   rbflag=1
fi

# 取消 sudo 輸入密碼操作
grep '%admin ALL=(ALL) ALL' /etc/sudoers &>/dev/null
if [ "$?" == "0" ];then
   grep -v '%admin ALL=(ALL) ALL' /etc/sudoers &>/tmp/sudoers.tmp
   echo "%admin ALL=(ALL) NOPASSWD: ALL" >> /tmp/sudoers.tmp
   cp /tmp/sudoers.tmp /etc/sudoers &>/dev/null
   [ "$?" == "0" ] && echo "$c. 取消 sudo 輸入密碼操作 完成"
   c=$(( c + 1 ))
fi

# 關閉螢幕保護功能
grep '# add by bobe' /etc/rc.local >/dev/null
if [ "$?" != "0" ] && [ "$xw" != "1" ]; then
   grep -v '^exit 0' /etc/rc.local &>/tmp/rc.local
   echo "# add by bobe" >> /tmp/rc.local
   echo -e "setterm -blength 0 -powersave off -blank 0\nexit 0" >> /tmp/rc.local
   cp /tmp/rc.local /etc/rc.local
   echo "$c. 關閉螢幕保護功能完成"
   c=$(( c + 1 ))
   rbflag=1
fi

# 取消 登入訊息檔 的顯示
if [ ! -f "$HOME/.hushlogin" ] && [ "$xw" != "1" ]; then
   touch "$HOME/.hushlogin"
   echo "$c. 取消登入訊息檔完成"
   c=$(( c + 1 ))
   rlflag=1
fi
c=$(( c - 1 ))
echo -e "共設定 $c 項目\n"

if [ "$rbflag" == "1" ];then
   read -p "重新開機 ? (y/n) " ans
   if [ "$ans" == "y" ]; then
      reboot
   fi
   echo ""
fi

if [ "$rlflag" == "1" ];then
   read -p "登出 ? (y/n) " ans
   if [ "$ans" == "y" ]; then
      logout
   fi
   echo ""
fi

exit 0

