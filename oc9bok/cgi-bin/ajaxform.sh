#!/bin/sh

# let the browser know that this is html code
echo "Content-type: text/html"
echo ""

# read in our parameters
ID=`echo "$QUERY_STRING" | sed -n 's/^.*id=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
TEXT=`echo "$QUERY_STRING" | sed -n 's/^.*text=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`

# our html code
echo "<html>"
echo "<head><title>Hello CGI</title></head>"
echo "<body>"

# test if any parameters were passed
if [ $ID ] && [ $TEXT ]
then
	echo "The parameters were set <br>"
	echo "the value of ID is $ID <br>"
	echo "the value of TEXT is $TEXT <br>"
        echo "$ID:$TEXT" > data/form.txt
else
	echo "<form method=get>"
	echo "ID : <input type=text name=id><br>"
	echo "TEXT : <input type=text name=text><br>"
	echo "TEXT : <input type=submit>"
	echo "</form>"
fi

echo "</body>"
echo "</html>"

