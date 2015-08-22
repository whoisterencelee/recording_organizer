#!/bin/sh

PROGRAM="$HOME/comskip/wine/comskip"
COMSKIP_CMD="wine $PROGRAM"
# use below for final test
# COMSKIP_CMD="echo $PROGRAM"
WAITING_DIR="$HOME/recording_organizer/channel/.waiting"
CORES=2
RECURSION_LIMIT=10

# require
PS_CMD="ps -ef"
GREP="grep -c"
READLINK="readlink"
LS="ls -tA"
EXPR="expr"
SRC=`dirname $0`
SCRIPT=$SRC/utils

for VARIABLES in PROGRAM COMSKIP_CMD WAITING_DIR CORES RECURSION_LIMIT; do
        [ -z "${!VARIABLES}" ] && echo "need to define $VARIABLES in $0" && exit 0
done

# check how many comskips are running and recursion stop condition
RUNNING=`$PS_CMD | $GREP "$PROGRAM"`
if [ $RUNNING -gt $CORES ]; then echo "too many $COMSKIP_CMD running"; exit 1; fi

# prevent runaway script
if [ ! -z "$1" ] && [ $1 -gt $RECURSION_LIMIT ]; then echo "$0 too much recursion, first check if your COMSKIP_CMD actually runs"; exit 1; fi

# get the next recording to process
for WAITING  in `$LS $WAITING_DIR`; do
	if [ -z "`$LSOF \"$WAITING_DIR/$WAITING\" 2> /dev/null`" ]; then
		RECORDING=`$READLINK "$WAITING_DIR/$WAITING"`
		break
	fi
done

if [ -z "$RECORDING" ]; then echo "no more recording is waiting"; exit 1; fi

if [ -z "$TEST" ]; then
	$COMSKIP_CMD $RECORDING && rm "$WAITING_DIR/$WAITING" &
else
	echo "$COMSKIP_CMD $RECORDING && rm "$WAITING_DIR/$WAITING" && $SRC/comskip.sh & $1 of $RECURSION_LIMIT tries"
fi

$SRC/comskip-processor.sh `$EXPR $1 + 1`
# keep running script recursively, stop when either cores or waiting recordings are used up
