#!/bin/sh

# put list of new recordings into subdirectories based on date information on filename
# format:  YYYY-MM-DD-channel-HHMM-HHMM-title.ts

# variables
# which hour to consider a new date, format hh
CUTOFF=02
RECORDING_DIR="$HOME/recording_organizer/recordings"
ORGANIZER_DIR="$HOME/recording_organizer/channel"
TEST=1

# requires:
EXPR="expr"
DATECONVERT="date -d"
LSOF="lsof"
SRC=`dirname $0`
SCRIPTS=$SRC/utils

# organize any new recordings by date directory
for RECORDING in `$SCRIPTS/files_created.sh $RECORDING_DIR`; do

	[ $? -eq 1 ] && echo "Need to define RECORDING_DIR" && exit 1;

	basename $RECORDING | sed -n '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-.*-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-.*.ts/'

	[ $? -eq 1 ] && continue;

	DATE=`basename $RECORDING | sed  's/^\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)-.*-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-.*.ts/\1/'`
	HOUR=`basename $RECORDING | sed  's/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-.*-\([0-9][0-9]\)[0-9][0-9]-[0-9][0-9][0-9][0-9]-.*.ts/\1/'`

	# continue if filename not in correct format
	if [ -z $HOUR ]; then
		echo $RECORDING filename not in correct format
		continue
	fi 

	# convert filename to epoch
	EPOCH=`$DATECONVERT "$DATE $HOUR:00" +%s`

	if [ $HOUR -lt $CUTOFF ]; then 

		# use EPOCH to take out the CUTOFF hours which should put it to previous day
		CUTOFFSEC=`$EXPR $CUTOFF \* 60 \* 60`
		#echo $CUTOFFHOUR $CUTOFFSEC

		EPOCH=`$EXPR $EPOCH - $CUTOFFSEC`
	fi

	# convert EPOCH to yyyy-mm-dd weekday
	DATE=`$DATECONVERT @$EPOCH +%Y-%m-%d\ %A`


	DATE_DIR="$ORGANIZER_DIR/$DATE"

	[ ! -d "$DATE_DIR" ] && [ -z $TEST ] && mkdir -p "$DATE_DIR"
	echo creating "$DATE_DIR"

	PLACED_PATH="$DATE_DIR/$RECORDING"

	# use hardlink so two copies of the file exists
	[ ! -e "$PLACED_PATH" ] && [ -z $TEST ] && ln "$RECORDING_DIR/$RECORDING" "$PLACED_PATH"
	echo $RECORDING_DIR/$RECORDING placed into $PLACED_PATH

	FLAG="$ORGANIZER_DIR/$RECORDING"

	# if file is finished recording create a link
	# touch doesn't affect link, so link will always be creation time
	# use lsof to check if recording is finished
	if [ ! -h "$FLAG" ] && [ -z "`$LSOF \"$PLACED_PATH\" 2> /dev/null`" ] 
	then
		# basically this tells the processor to process the file
		# because the processor is over the network, need to use filesystem
		# to pass messages
		[ -z $TEST ] && ln -s "$PLACED_PATH" "$FLAG"
		echo soft linked "$FLAG" to "$PLACED_PATH"
	fi

done
exit 0
