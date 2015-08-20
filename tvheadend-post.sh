#!/bin/sh

# put list of new recordings into subdirectories based on date information on filename
# format:  YYYY-MM-DD-channel-HHMM-HHMM-title.ts

# variables
# when to consider a new day format hhmm
CUTOFF=0101
RECORDING_DIR="$HOME/recording_organizer/recordings"
ORGANIZER_DIR="$HOME/recording_organizer/output"

# requires:
EXPR="expr"
DATECONVERT="date -d"
LSOF="lsof"
SRC=`dirname $0`
SCRIPTS=$SRC/utils

# organize any new recordings by date directory
for RECORDING in `$SCRIPTS/files_created.sh $RECORDING_DIR`; do

	# convert filename to epoch
	TIME=`basename $RECORDING | sed  's/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-.*-\([0-9][0-9][0-9][0-9]\)-[0-9][0-9][0-9][0-9]-.*.ts/\1/'`
	DATE=`basename $RECORDING | sed  's/^\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)-.*-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-.*.ts/\1/'`

	# continue if filename not in correct format
	if [ -z $TIME ] || [ -z $DATE ]; then continue; fi 

	EPOCH=`$DATECONVERT "$DATE $TIME" +%s`

	if [ $TIME -lt $CUTOFF ]; then 

		# use EPOCH to take out the CUTOFF hours which should put it to previous day
		CUTOFFHOUR=`echo $CUTOFF | sed 's/^\([0-9][0-9]\)[0-9][0-9].*/\1/'`
		CUTOFFMIN=`echo $CUTOFF | sed 's/^[0-9][0-9]\([0-9][0-9]\).*/\1/'`
		CUTOFFSEC=`$EXPR $CUTOFFHOUR \* 60 \* 60 + $CUTOFFMIN \* 60`
		#echo $CUTOFFHOUR $CUTOFFMIN $CUTOFFSEC

		EPOCH=`$EXPR $EPOCH - $CUTOFFSEC`
	fi

	# convert EPOCH to yyyy-mm-dd weekday
	DATE=`$DATECONVERT @$EPOCH +%Y-%m-%d\ %A`

	DATE_DIR="$ORGANIZER_DIR/$DATE"

	[ ! -d "$DATE_DIR" ] && mkdir -p "$DATE_DIR"

	PLACED_PATH="$DATE_DIR/$RECORDING"

	# use hardlink so two copies of the file exists
	[ ! -e "$PLACED_PATH" ] && ln "$RECORDING_DIR/$RECORDING" "$PLACED_PATH"

	echo $RECORDING_DIR/$RECORDING placed into $PLACED_PATH

	# if file is finished recording create a link
	# use lsof to check if recording is finished
	if [ ! -h "$PLACED_PATH" ] && [ -z "`$LSOF \"$PLACED_PATH\" 2> /dev/null`" ] 
	then
		# basically this tells the processor to process the file
		# because the processor is over the network, need to use filesystem
		# to pass messages
		ln -s "$PLACED_PATH" "$ORGANIZER_DIR/$RECORDING"
	fi

done
exit 0
