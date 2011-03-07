#!/bin/bash
#
# oc9exam.sh
#
# Copyright (C) 2011 "Sung-Ling Chen"  <oc99.98@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/Licenses/>.
#
#  exam format :
#    1. 題庫
#    2. 範圍
#    3. 題數
#
########################################################################################

f=$(cat $1$2)

s=$(echo $f | cut -d":" -f 1)
l=$(echo $f | cut -d":" -f 2)
n=$(echo $f | cut -d":" -f 3)

[ $n -lt 30 ] && n=30
[ $n -gt 62 ] && n=62

[ ! -f $1/oc9info.txt ] && exit 1

tp=$(grep "$s" $1/oc9info.txt | cut -d":" -f 2)
tp=$(echo $tp | tr -d "'" | tr -d ",")

ep=$(grep "ExamDIR" $1/oc9info.txt | cut -d":" -f 2)
ep=$(echo $ep | tr -d "'" | tr -d ",")

wip=$(grep "OC9IP" $1/oc9info.txt | cut -d":" -f 2)
wip=$(echo $wip | tr -d "'" | tr -d ",")

tp=$1../$ep/$s/test.db

# 讀入考題
sx=$(cat $tp | sed -n "/<$l>/,/<\/$l>/p" | grep -v "$l")

declare -a Exams

index=0
for i in $sx
do
   e=$(echo $i | cut -d':' -f 1)
   Exams[$index]="'http://$wip/$s/$l/$e',"
   let "index=$index+1"
done

# 打亂考題順序
c=0
while [ $c -lt $index ]
do
  r1=$(($RANDOM % $index))
  r2=$(($RANDOM % $index))

  temp="${Exams[$r1]}"
  Exams[$r1]="${Exams[$r2]}"
  Exams[$r2]="$temp"

  let "c=$c+1"
done

# 出考題
index=0
echo "[" > /tmp/"$s"_$l
while [ $index -lt $n ]
do
   echo "${Exams[$index]}" >> /tmp/"$s"_$l
   let "index=$index+1"
done
echo "]" >> /tmp/"$s"_$l

# 派送考題

ul=$(cat $1/users)
for i in $ul
do
   u=$(echo $i | cut -d":" -f 1)
   cp /tmp/"$s"_$l /home/$u/$ep
done

mv $1/exam $1/out/$4_exam
#rm $1/exam > /dev/null



