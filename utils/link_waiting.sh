#!/bin/sh

# returns the oldest link for processing

# require
LS="ls -tAr"
#LSOF="lsof" # can't use over network
READLINK="readlink"
FIND="find . -type l"

cd $1
for LINK in `$LS \`$FIND\``; do

	# check the file exists and not recording or comskipping
	if [ -e `$READLINK $LINK` ] && [ -z "`$LSOF $LINK 2> /dev/null`" ]
	then
	  echo $LINK
	  exit 0
	fi
done
exit 1
