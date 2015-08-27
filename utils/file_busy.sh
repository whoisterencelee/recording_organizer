#!/bin/sh

# require
PS="ps"
GREP="grep"
SED="sed"
LS="ls -Al"
READLINK="readlink -f"

# check if -e flag is required
$PS -e &> /dev/null
[ $? -eq 0 ] && PS="ps -e"

FILE=`$READLINK $2`

PIDS=`$PS | $GREP $1 | $SED 's/\([0-9]\+\).*/\1/'`
for PID in $PIDS; do
	FOUND=`$LS /proc/$PID/fd 2> /dev/null | $GREP "$FILE"`
	[ -n "$FOUND" ] && exit 1
done
exit 0
