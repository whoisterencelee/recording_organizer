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

for VARIABLES in CUTOFF RECORDING_DIR ORGANIZER_DIR; do
	[ -z ${!VARIABLES} ] && echo "need to define $VARIABLES in $SRC/tvheadend.sh" && exit 0
done

# organize any new/modified recordings by date directory
for RECORDING in `$SCRIPTS/files_created.sh $RECORDING_DIR`; do

	# continue if filename not in correct format
	CHECK=`basename $RECORDING | sed -n '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-.*-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-.*.ts/p'`
	[ -z "$CHECK" ] && continue;

	DATE=`basename $RECORDING | sed  's/^\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)-.*-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-.*.ts/\1/'`
	HOUR=`basename $RECORDING | sed  's/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-.*-\([0-9][0-9]\)[0-9][0-9]-[0-9][0-9][0-9][0-9]-.*.ts/\1/'`

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

	# if file is finished recording create a link
	# because the processor is over the network, need to use filesystem to pass messages
	# use lsof to check if recording is finished
	if [ -z "`$LSOF \"$PLACED_PATH\" 2> /dev/null`" ] 
	then
		# this tells the processor to process the file
		# -f always replaces old symbolic with the new symbolic
		# since the loop starts from newest to oldest recording, the oldest recording will have the newest symbolic link
		# and we can use utils/file_created.sh again at the processor to process the oldest recording first
		FLAG="$ORGANIZER_DIR/$RECORDING"

		[ -z $TEST ] && ln -sf "$PLACED_PATH" "$FLAG"

		echo flag "$PLACED_PATH" by creating symbolic link "$FLAG"
	fi

done
exit 0
