#!/bin/bash
#
# random20.sh
#

c=0
while [ $c -le 20 ]
do
  r=$(( ($RANDOM % 20)+1 ))
  echo $r
  let "c=$c+1"
done
