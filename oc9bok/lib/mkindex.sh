#!/bin/bash
# mkdirhtml.sh

declare -a DIR_NAME
declare -a FILE_NAME

E_NOARGS=70   # No arguments error

C_DIR=0
C_FILE=0


if [ $# != 2 ]; then
    echo "Usage: "$0" dirName userName"
    exit $E_NOARGS    
fi

echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">" > "$1/index.html"
echo "<meta http-equiv="Expires" content="0"></head>" >> "$1/index.html"
echo "<body><h1>$2 網站</h1><hr>" >> "$1/index.html"

for x in $1/*
do 
  if [ -d "$x" ]; then
     DIR_NAME[$C_DIR]="$x"
     let "C_DIR=$C_DIR+1"
     continue
  fi
  if [ "${x##*\\}" != "${x%%\\*}" ]; then
     mv "$x" "${x%%\\*}/${x##*\\}"
     continue
  fi
  FILE_NAME[$C_FILE]="$x"
  let "C_FILE=$C_FILE+1"
done

index=0
while [ "$index" -lt "$C_DIR" ]
do
   x="${DIR_NAME[$index]}"
   echo "<b><a href=\"${x##*/}/\">${x##*/}</a></b><br>" >> "$1/index.html"
   let "index=$index+1"
done

index=0
while [ "$index" -lt "$C_FILE" ]
do
  x="${FILE_NAME[$index]}"
  if [ ${x##*/} != "index.html" ]; then
     echo "<a href=${x##*/}>${x##*/}</a><br>" >> "$1/index.html"
  fi
  let "index=$index+1"
done

echo "<hr></body></html>" >> "$1/index.html"
unset DIR_NAME
unset FILE_NAME
