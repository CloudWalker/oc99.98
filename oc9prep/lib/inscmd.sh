#!/bin/bash

[ "$USER" != "root" ] && echo "需要 root 權限" && exit 1

#ping -c 2 168.95.1.1 &>/dev/null
#[ "$?" != "0" ] && echo "外網不通 (168.95.1.1)" && exit 1

cmd='fping tree expect convmv mingetty acpid dialog nbtscan'

echo "套件安裝如下 :"
echo "--------------------"
n=0
for c in $cmd
do
    which $c &>/dev/null
    if [ "$?" != "0" ]; then
       n=$(( n + 1 ))
       echo -n "$n. 安裝 $c "
       apt-get -y --force-yes install $c &>/dev/null
       if [ "$?" == "0" ]; then 
         echo "完成"
       else
         echo "失敗"
       fi
    fi
done
echo -e "共安裝 $n 套件\n"

