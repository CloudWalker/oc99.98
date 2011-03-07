#!/bin/bash
#
# inkeydemo.sh
#
old_tty_setting=$(stty -g) #Save old terminal settings
stty -icanon -echo time 2 min 0 #Disable canonical mode and echo

while [ 1 ] 
do

  keys=$(dd bs=1 count=1 2>/dev/null)
  [ "$keys" == "d" ] && break

done

stty "$old_tty_setting" #Restore old terminal settings
