#!/bin/bash

[ "$USER" != "root" ] && echo "要 root 權限" && exit 1
[ "$LANG" != "zh_TW.UTF-8" ] && echo "語系不對, 必須是 zh_TW.UTF-8" && exit 1

# 安裝命令 (fping, tree, expect, convmv)
. $HOME/bin/lib/inscmd.sh

u=$(ls /home)
echo "" >/tmp/convmv.msg

for z in $u
do
   [ -d /tmp/www ] && rm -r /tmp/www &>/dev/null
   
   if [ -d /home/$z/www ]; then
      cp -rP /home/$z/www /tmp/www &>/dev/null

      convmv -r --notest -f utf-8 -t big5 /tmp/www &>>/tmp/convmv.msg
      [ "$?" != "0" ] && echo "轉碼失敗" && exit 1

      cd /tmp/ &>/dev/null
      zip -r $z www &>/dev/null
      [ "$?" != "0" ] && echo "$z.zip 壓縮失敗" && exit 1

      cp $z.zip /home/$z/ &>/dev/null
      chown $z:$z /home/$z/$z.zip &>/dev/null
      [ "$?" == "0" ] && echo "$z.zip 產生成功"
    fi

done 
