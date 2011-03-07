#!/bin/bash
echo "Content-type: text/html; charset=UTF-8"
echo "Status: 200 OK"
echo ""

POST_DATA=$(</dev/stdin)

echo "<script>alert(decodeURI('${POST_DATA}'))</script>"
