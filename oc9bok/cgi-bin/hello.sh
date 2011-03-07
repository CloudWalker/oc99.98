#!/bin/bash

echo Content-type: text/html
echo ""
echo "<html>"
echo "<body>"
echo "<h1>CGI Test</h1>"
echo "<pre>"
env
echo "</pre>"
echo "</body>"
echo "</html>"

