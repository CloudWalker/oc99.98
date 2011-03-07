#!/bin/bash

# 檢查是否有給帳號數量
[ -z $1 ] && echo "請給建立使用者帳號的數量" && exit 1

# 檢查 $1 是否為數字
s=$(echo $1 | tr -d 0-9)
[ -n "$s" ] && echo "$1 不是數字" && exit 1

# 檢查是否已產生帳號 ? 如存在便將它們全部刪除
if [ -d "/home/lcj01" ]; then
   echo -n "lcjxx 使用者帳號已存在, 是否要全部刪除 ? (y/n) :"
   read -e Answer
   echo "" 
   if [ "$Answer" == "y" ]; then 
      clear
      i=0
      while [ "$i" != "50" ]
      do
        i=$(($i+1))  
        # 刪除使用者帳號
        s=$(printf "%02d" $i)    # 個位數會補個 0
        userdel -r "lcj$s" &>/dev/null
        [ $? != 0 ] && echo "請再執行一次 clouduser 命令, 新增帳號" && exit 0
        echo "lcj$s 使用者帳號, 已刪除" 
        [ -d /var/www/ ] && rm -f "/var/www/lcj$s"
      done
      echo "請再執行一次 clouduser 命令, 新增帳號"
      exit 0
   fi
fi

# 最多 50 個帳號
max=50
[ $1 -lt 50 ] && max=$1
 
# 開始批次建立使用者帳號
clear
echo "開始批次建立 $max 個使用者帳號, 請稍後 ...."
echo "" 


ll=0
if [ -d /var/www/ ]; then 
   ll=1
fi

i=0
while [ "$i" != "$max" ]
do
  i=$(($i+1))

  # 設定密碼為 'goforwin'
  pass=$(perl -e 'print crypt($ARGV[0], "password")' 'goforwin')

  # 建立使用者帳號
  s=$(printf "%02d" $i)    # 個位數會補個 0 字元
  echo "lcj$s 使用者帳號, 建立中......" 
  useradd -m -s /bin/bash -p $pass "lcj$s" 

  # 建立簡易虛擬目錄名稱
  if [ "$ll" == "1" ]; then 
     ln -s "/home/lcj$s/豆知識網站" "/var/www/lcj$s" 
     ./mkindex.sh "/home/lcj$s/豆知識網站" "lcj$s"
  fi
done
exit 0

