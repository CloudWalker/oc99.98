#!/bin/bash

#  必須是 root 帳號執行
[ "$USER" != "root"  ] && echo "需要 root 權限" && exit 1  
                    
# 檢查是否為 Desktop 版本, 如為 Desktop 版本 xw 設定為 1
[ -n "$DISPLAY" ] && echo -n "此為 Desktop 版本, 按任何按鍵繼續.. ";read && exit 1

# 取出網卡名稱 (eth0, eth1, ...)
ifconfig -a | grep eth > /tmp/net.txt
n=$(cat /tmp/net.txt | cut -d ' ' -f1 | fmt -u)

for  e  in $n
do
    ip=$(ifconfig -a | grep -A1 $e | grep 'inet addr')
    ip=${ip#*:}
    ip=${ip%% *}

    cat /etc/network/interfaces | grep "$e.*dhcp" &>/dev/null
    if [ "$?" == "0" ]; then
       echo "$e : $ip (dhcp)"
    else
       # 如是 KVM 主機有可能 eth0 沒有 IP 位址, 因被 br0 佔用
       if [ -n "$ip" ]; then
          echo "$e : $ip"
          read -p "設定 IP (y/n) ? " ans
          if [ "$ans" == "y" ]; then
             read -p "請輸入新 IP  : " nip

             #  將修改後的結果, 寫入 /tmp/chgip.tmp
             cat /etc/network/interfaces | sed "s/$ip/$nip/" &> /tmp/chgip.tmp     
         
             #  將 /tmp/chgip.tmp 覆蓋 /etc/network/interfaces
             [ "$?" == 0 ] && cp /tmp/chgip.tmp /etc/network/interfaces &>/dev/null          
             # ifdown $e
             # ifup $e
          fi
       fi 
    fi
done

exit 0

