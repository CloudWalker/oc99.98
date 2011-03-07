#!/bin/bash

# let the browser know that this is html code
echo "Content-type: text/html"
echo ""

# read in our parameters
ID=`echo "$QUERY_STRING" | sed -n 's/^.*id=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
#PASS=`echo "$QUERY_STRING" | sed -n 's/^.*pass=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
#TEXT=`echo "$QUERY_STRING" | sed -n 's/^.*text=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`

if [ ! -z "$ID" ]; then
   if [ ! -f data/users.db ]; then
      echo "<script>alert('失敗!!')</script>"
      return
   fi
   grep "<div id='$ID'>" data/users.db &>/dev/null
   if [ "$?" == "0" ]; then
      echo "<script>alert('成功!')</script>"
   else
      echo "<script>alert('失敗!')</script>"
   fi
else
   echo "<script>alert('失敗!')</script>"
fi

