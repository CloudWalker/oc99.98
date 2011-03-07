#!/bin/bash
#
# oc9mondir.sh
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
########################################################################################

# 此程式必須是 root 執行
[ "$USER" != "root" ] && echo "需要 root 權限" && exit 1

if [ "$1" == "stop" ]; then
    killall -9 oc9mondir.sh
    killall -9 inotifywait
    exit 0 
fi

[ ! -d $1 ] && echo "$1 目錄不存在" && exit 1

[ ! -d $1/out ] && mkdir $1/out
[ ! -d $1/bad ] && mkdir $1/bad
echo > $1/cmdfile.log

inotifywait -mq --timefmt "%m_%d_%H_%M_%S" --format "%w %f %e %T" -e create $1 | 
while read p f a t;
do 
   echo "$p$f" $a $t >> $1/cmdfile.log
   (./oc9monrun.sh $p $f $a $t &)
done



