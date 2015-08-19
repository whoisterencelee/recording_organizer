#!/bin/sh

# checks when files in spool is complete
# this also runs in post script and cron

# require
LS="ls -tAr"
LSOF="lsof"
READLINK="readlink"
FIND="find . -type l"

for LINK in `$LS \`$FIND\``; do

	# check the file exists and not recording or comskipping
	if [ -e `$READLINK $LINK` ] && [ -z "`$LSOF $LINK 2> /dev/null`" ]
	then
	  echo $LINK
	  exit 0
	fi
done
exit 1
