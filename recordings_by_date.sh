#!/bin/sh

# put list of new recordings into subdirectories based on date information on filename
# format:  YYYY-MM-DD-channel-HHMM-HHMM-title.ts

# variables
# when to consider a new day format hhmm
CUTOFF=0101

# requires:
EXPR="expr"
DATECONVERT="date -d"

RECORDING=$*

# convert filename to epoch
TIME=`basename $RECORDING | sed  's/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-.*-\([0-9][0-9][0-9][0-9]\)-[0-9][0-9][0-9][0-9]-.*/\1/'`
DATE=`basename $RECORDING | sed  's/^\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)-.*-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-.*/\1/'`
EPOCH=`$DATECONVERT "$DATE $TIME" +%s`

if [ $TIME -lt $CUTOFF ]; then 
	# use EPOCH to take out the CUTOFF hours which should put it to previous day

	CUTOFFHOUR=`echo $CUTOFF | sed 's/^\([0-9][0-9]\)[0-9][0-9].*/\1/'`
	CUTOFFMIN=`echo $CUTOFF | sed 's/^[0-9][0-9]\([0-9][0-9]\).*/\1/'`
	CUTOFFSEC=`$EXPR $CUTOFFHOUR \* 60 \* 60 + $CUTOFFMIN \* 60`
	#echo $CUTOFFHOUR $CUTOFFMIN $CUTOFFSEC

	EPOCH=`$EXPR $EPOCH - $CUTOFFSEC`
fi

DATE=`$DATECONVERT @$EPOCH +%Y-%m-%d\ %A`
echo $DATE

mkdir -p "$DATE"

# use hardlink so two copies of the file exists
ln $RECORDING "$DATE"/$RECORDING
