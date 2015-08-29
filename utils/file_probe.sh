#!/bin/sh
# probe if file size has changed continuously for a period of 1 minute

# usage:  file-probe.sh <file to probe> <run command if file no change>
# <file to probe> can have wildcard or just a partial filename, can have date formats

# use complicated cron setup to probe, for example:
# 01 20 * * *  file-probe.sh %Y-%m-%d-channel-2000-2030-test	               # can probe as soon as file starts changing
# 25 20 * * *  file-probe.sh %Y-%m-%d-channel-2000-2030-test <email script>    # set to probe near end with time enough for one last reboot

# require
DU="du -c"
DATE="date"
SED="sed"

# use an external program like cron to probe if a recording started

FILE=`$DATE +$1`
OLD_SIZE=`eval "$DU $FILE" | $SED '$!d' | $SED 's/\([0-9]\+\)\s\+total/\1/g'`
sleep 60
NEW_SIZE=`eval "$DU $FILE" | $SED '$!d' | $SED 's/\([0-9]\+\)\s\+total/\1/g'`

# if file doesn't exists, the total would be 0 and would match and still reboot

[ $OLD_SIZE -eq $NEW_SIZE ] && echo "rebooting due to file: $FILE is not busy" && $2
