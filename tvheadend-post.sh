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
	[ -z ${!VARIABLES} ] && echo "need to define $VARIABLES in $0" && exit 0
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

	# processor is over the network, use filesystem to pass messages
	# use lsof to check if recording is finished, if recording is finished create a link
	# need to know which directory the recording is in, because processor needs to place supplementary file in the same directory
	# hardlink cannot do that, use symbolic link 
	if [ -z "`$LSOF \"$PLACED_PATH\" 2> /dev/null`" ] 
	then
		WAITING_DIR="$ORGANIZER_DIR/.waiting"
		[ -z $TEST ] && mkdir -p "$WAITING_DIR"

		FLAG="$WAITING_DIR/$RECORDING"

		# ln -sf always replaces old symbolic with the new symbolic
		# since the main loop starts from latest to oldest *modified* recording
		# the oldest *modified* recording will have the newest symbolic link
		# so processing should start on oldest *modified* first
		# previously stuck *not modified* recording will still be last in the processing
		[ -z $TEST ] && ln -sf "$PLACED_PATH" "$FLAG"

		echo flag "$PLACED_PATH" by creating symbolic link "$FLAG"
	fi

done
exit 0
