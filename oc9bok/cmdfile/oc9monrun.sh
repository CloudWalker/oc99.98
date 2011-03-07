#!/bin/bash
#
# oc9monrun.sh
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

case  $2 in
     login)
         l=$(cat "$1$2")
         u=${l%:*}
         p=${l#*:}

         [ -f $1/out/"$u"_ok ] && rm $1/out/"$u"_ok

         grep $u /etc/shadow >/dev/null
         if [ "$?" == "0" ]; then
            slat=$(cat /etc/shadow | grep $u | cut -d':' -f 2 | cut -d'$' -f 3)
            cp=$(mkpasswd -S $slat -m SHA-512 $p)
            grep $cp /etc/shadow > /dev/null
            if [ "$?" == "0" ]; then
               touch $1out/"$u"_ok
            fi 
         fi
         rm $1$2 >/dev/null
          ;;
     logout)
        u=$(cat $1$2)
        [ -f $1/out/"$u"_ok ] && rm $1/out/"$u"_ok
        rm $1$2 >/dev/null
         ;;
     backup)
        (./oc9backup.sh $1 $2 $3 $4) &
         ;;
     copyto)
        (./oc9copy.sh $1 $2 $3 $4) &
         ;;
     exam)
        (./oc9exam.sh $1 $2 $3 $4) &
         ;;
      *)
        if [ -f $1$2 ]; then
           rm $1$2 &>/dev/null
           echo "$2 not recognized." > $1/bad/$4-$2
        else
           rm -r $1New* >/dev/null
        fi
         ;;
esac

