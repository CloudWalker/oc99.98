#!/bin/bash

ping -c 2 168.95.1.1 &>/dev/null
[ "$?" != "0" ] && echo "外網不通 (168.95.1.1)" && exit 1

cmd='fping tree expect'
n=0

echo "套件安裝如下 :"
echo "--------------------"
for c in $cmd
do
    which $c &>/dev/null
    if [ "$?" != "0" ]; then
       echo -n "$n. 安裝 $c "
       apt-get -y --force-yes install $c &>/dev/null
       if [ "$?" == "0" ]; then 
         n=$(( n +1 ))
         echo "完成"
       else
         echo "失敗"
       fi
    fi
done
echo -e "共安裝 $n 套件\n"

