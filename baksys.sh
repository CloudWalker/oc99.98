#!/bin/sh
DIR=/media/DATA
DATE=`date +%Y-%m-%d`
FILE=full-$DATE.dump

dump -0 -u -b 64 -f $DIR/$FILE / 
