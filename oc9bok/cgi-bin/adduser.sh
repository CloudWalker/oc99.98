#!/bin/bash

# let the browser know that this is html code
echo "Content-type: text/html"
echo ""

# read in our parameters
ID=`echo "$QUERY_STRING" | sed -n 's/^.*id=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
PASS=`echo "$QUERY_STRING" | sed -n 's/^.*pass=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
TEXT=`echo "$QUERY_STRING" | sed -n 's/^.*text=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`

[ ! -f data/users.db ] && touch data/users.db

if [ ! -z "$ID" ]; then
   grep "<div id='$ID'>" data/users.db &>/dev/null
   if [ "$?" == "0" ]; then
      echo  "<script>alert('建立失敗')</script>"
   else
      echo -e "<div id='$ID'>\n  <div>$ID</div>\n  <div>$PASS</div>\n  <p>$TEXT</p>\n</div>" >> data/users.db
      echo  "<script>alert('建立成功')</script>"
   fi
else
      echo  "<script>alert('建立失敗')</script>"
fi

