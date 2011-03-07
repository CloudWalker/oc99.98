#!/bin/bash

[ "$USER" != "root" ] && echo "需要 root 權限" && exit 1
n=$(cat /etc/resolv.conf | grep nameserver | fmt -u | sed 's/nameserver//g')

for  d  in $n
do
   echo "Nameserver : $d"
   read -p "設定新的 DNS 位址 (y/n) ? " ans
   if [ "$ans" == "y" ]; then
      read -p "請輸入新的 DNS 位址 : " nd
      cat /etc/resolv.conf | sed "s/$d/$nd/" >/tmp/dns.chg
      cp /tmp/dns.chg /etc/resolv.conf &>/dev/null
   fi
done

exit 0

