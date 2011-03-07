#!/bin/bash
#
# oc9copyto.sh
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
#  copyto format :
#    1. source
#    2. type
#    3. destination
#
########################################################################################

f=$(cat $1$2)
s=$(echo $f | cut -d":" -f 1)
t=$(echo $f | cut -d":" -f 2)
d=$(echo $f | cut -d":" -f 3)

case  $t  in
     zip)

          ;;
     file)
        u=$(cat $1$2)
        [ -f $1/out/"$u"_ok ] && rm $1/out/"$u"_ok
        rm $1$2 >/dev/null
         ;;
     tar)
        (./oc9backup.sh $1 $2 $3 $4) &
         ;;
      *)
        rm $1$2 >/dev/null
        echo "$t not recognized." > $1/bad/$4-$2
         ;;
esac


