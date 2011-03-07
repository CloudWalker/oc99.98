#!/bin/bash

[ "$USER" != "root" ] && echo "需要 root 權限" && exit 1

g=$(grep gateway /etc/network/interfaces)
gw=${g##* }

if [ -n "$gw" ]; then
   echo "Gateway : $gw"
   read -p "設定新的 Gateway 位址 (y/n) ? " ans
   if [ "$ans" == "y" ]; then
      read -p "請輸入新的 Gateway 位址 : " ngw
      cat /etc/network/interfaces | sed "s/$gw/$ngw/" &> /tmp/chggw.tmp
      [ "$?" == 0 ] && cp /tmp/chggw.tmp /etc/network/interfaces && echo "設定完成"
   fi
fi

exit 0

