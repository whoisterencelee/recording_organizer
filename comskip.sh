#!/bin/sh

CORES=2
COMSKIP_CMD="wine ~/comskip/wine/comskip"

# require
PS_CMD="ps -e"
GREP="grep"
WC="wc -l"

# organize any new recordings by date directory
files_created.sh | xargs recordings_by_date.sh

# check how many comskips are running
RUNNING=`$PS_CMD | $GREP "$COMSKIP_CMD" | $WC`
if [ $RUNNING -gt $CORES ]; then exit 1; fi

WAITING=link_waiting.sh
if [ -z $WAITING ]; then exit 1; fi

RECORDING=`readlink $WAITING`

echo "$COMSKIP_CMD $RECORDING && rm $WAITING || comskip.sh &"
#$COMSKIP_CMD $RECORDING && rm $WAITING || comskip.sh &
