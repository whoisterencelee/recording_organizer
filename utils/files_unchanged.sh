#!/bin/sh
# probe if file(s) size has changed in the last minute

# usage:  file_unchanged.sh "<file(s) to probe>"
# <file(s) to probe> can have wildcard or just a partial filename, can have date formats

# EXAMPLE
# use cron to probe and reboot if file is not busy
# 01 20 * * *  file_unchanged.sh %Y-%m-%d-channel-2000-2030-test* && reboot               # can probe as soon as file starts changing
# 25 20 * * *  file_unchanged.sh %Y-%m-%d-channel-2000-2030-test* && email.sh && reboot   # set to probe near end with time enough for one last reboot

# require
DU="du -c"
DATE="date"
SED="sed"
SLEEP="sleep 10"

echo $1
FILE=`$DATE +$1`
echo probing $FILE
OLD_SIZE=`eval "$DU $FILE" | $SED '$!d' | $SED 's/\([0-9]\+\)\s\+total/\1/g'`
$SLEEP
NEW_SIZE=`eval "$DU $FILE" | $SED '$!d' | $SED 's/\([0-9]\+\)\s\+total/\1/g'`

# if file doesn't exists, the total would be 0 and would match and still return 0

[ $OLD_SIZE -eq $NEW_SIZE ] && echo "file: $FILE is unchanged" && exit 0
exit 1
