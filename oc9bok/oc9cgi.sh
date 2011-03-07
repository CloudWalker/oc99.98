#!/bin/bash

[ "$USER" != "root" ] && echo "需要 root 權限" && exit 1
which apache2 &>/dev/null
[ "$?" != "0" ] && echo "請安裝 Apache 伺服器" && exit 1

u=$(ls /home)

for z in $u
do
   if [ ! -d /home/$z/www/cgi-bin ]; then
      mkdir /home/$z/www/cgi-bin &>/dev/null
      [ "$?" == "0" ] && echo "$z cgi-bin 目錄建立完成"

      cp ./cgi-bin/*.* /home/$z/www/cgi-bin/ &>/dev/null 

      mkdir /home/$z/www/cgi-bin/data &>/dev/null
      if [ "$?" == "0" ]; then
         chown root:www-data /home/$z/www/cgi-bin/data &>/dev/null
         chmod 775 /home/$z/www/cgi-bin/data &>/dev/null
         [ "$?" == "0" ] &&  echo -e "$z cgi-bin/data 目錄建立完成\n"
      fi
   else
      cp ./cgi-bin/*.* /home/$z/www/cgi-bin/ &>/dev/null
      [ "$?" == "0" ] && echo "$z CGI 程式複製成功"
   fi
done 

