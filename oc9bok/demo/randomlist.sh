#!/bin/bash
#
# randomlist.sh
#

declare -a Files

DIR="."
SUFFIX="sh"
index=0
for i in "$DIR"/*.$SUFFIX
do
    Files[$index]="${i%%.$SUFFIX}"
    let "index=$index+1"
done

# 打亂檔案清單順序
c=0
while [ $c -lt $index ]
do
  r1=$(($RANDOM % $index))
  r2=$(($RANDOM % $index))

  temp="${Files[$r1]}"
  Files[$r1]="${Files[$r2]}"
  Files[$r2]="$temp"

  let "c=$c+1"
done

c=0
while [ $c -lt $index ]
do
  echo "${Files[$c]}"
  let "c=$c+1"
done

