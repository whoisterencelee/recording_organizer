#!/bin/sh

PROGRAM="$HOME/comskip/wine/comskip.exe"
COMSKIP_CMD="wine $PROGRAM"
# use below for final test
# COMSKIP_CMD="echo $PROGRAM"
WAITING_DIR="$HOME/recording_organizer/channel/.waiting"
CORES=2
RECURSION_LIMIT=10
#TEST=1

# require
PS_CMD="ps -ef"
GREP_COUNT="grep -c"
LSOF="lsof"
READLINK="readlink"
LS="ls -tA"
EXPR="expr"
SRC=`dirname $0`
SCRIPT=$SRC/utils

for VARIABLES in PROGRAM COMSKIP_CMD WAITING_DIR CORES RECURSION_LIMIT; do
	[ -z "$( eval "echo \$$VARIABLES" )" ] && echo "need to define $VARIABLES in $0" && exit 0
done

# check how many comskips are running and recursion stop condition
RUNNING=`$PS_CMD | $GREP_COUNT "$PROGRAM"`
if [ $RUNNING -gt $CORES ]; then echo "too many $COMSKIP_CMD running"; exit 1; fi

# prevent runaway script
if [ ! -z "$1" ] && [ $1 -gt $RECURSION_LIMIT ]; then echo "$0 too much recursion, either too many files to process or first check if your COMSKIP_CMD actually runs"; exit 1; fi

# get the next recording to process
for WAITING  in `$LS $WAITING_DIR`; do
	LINK="$WAITING_DIR/$WAITING" 
	# checking if $LINK is already processing
	if [ -z "`$LSOF \"$LINK\" 2> /dev/null`" ]; then
		RECORDING=`$READLINK "$WAITING_DIR/$WAITING"`
		break
	fi
done

if [ -z "$RECORDING" ]; then echo "no more recording is waiting"; exit 1; fi

if [ -z "$TEST" ]; then
	$COMSKIP_CMD "$WAITING_DIR/$RECORDING" && rm "$LINK" &
else
	echo "$COMSKIP_CMD \"$WAITING_DIR/$RECORDING\" && rm \"$LINK\" && $SRC/comskip.sh & $1 of $RECURSION_LIMIT tries"
fi

# keep running script recursively, stop when either cores or waiting recordings are used up
# need a small wait for wine to initialize and run comskip
sleep 20s
$SRC/comskip-processor.sh `$EXPR $1 + 1`
