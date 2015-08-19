#!/bin/sh

CORES=2
COMSKIP_CMD="wine $HOME/comskip/wine/comskip"
RECORDING_DIR="$HOME/recording_organizer/recordings"
OUTPUT_DIR="$HOME/recording_organizer/output"

# require
PS_CMD="ps -e"
GREP="grep"
WC="wc -l"
SRC=`dirname $0`
READLINK="readlink"

# organize any new recordings by date directory
#$SRC/files_created.sh $RECORDING_DIR | xargs $SRC/recordings_by_date.sh $RECORDING_DIR $OUTPUT_DIR

# check how many comskips are running
RUNNING=`$PS_CMD | $GREP "$COMSKIP_CMD" | $WC`
if [ $RUNNING -gt $CORES ]; then echo "too many $COMSKIP_CMD running"; exit 1; fi

WAITING=`$SRC/link_waiting.sh $OUTPUT_DIR`
if [ -z "$WAITING" ]; then exit 1; fi

RECORDING=`$READLINK $WAITING`

echo "$COMSKIP_CMD $RECORDING && rm $WAITING || comskip.sh &"
#$COMSKIP_CMD $RECORDING && rm $WAITING || comskip.sh &
