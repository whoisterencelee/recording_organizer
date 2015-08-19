#!/bin/sh

PROGRAM="$HOME/comskip/wine/comskip"
COMSKIP_CMD="wine $PROGRAM"
ORGANIZER_DIR="$HOME/recording_organizer/output"
CORES=2

# require
PS_CMD="ps -ef"
GREP="grep -c"
SRC=`dirname $0`
SCRIPTS=$SRC/utils
READLINK="readlink"

# check how many comskips are running
RUNNING=`$PS_CMD | $GREP "$PROGRAM"`
if [ $RUNNING -gt $CORES ]; then echo "too many $COMSKIP_CMD running"; exit 1; fi

# get the next recording to process
WAITING=`$SCRIPTS/link_waiting.sh "$ORGANIZER_DIR"`
if [ -z "$WAITING" ]; then exit 1; fi

RECORDING=`$READLINK $WAITING`

echo "$COMSKIP_CMD $RECORDING && rm "$ORGANIZER_DIR/$WAITING" || $SRC/comskip.sh &"
