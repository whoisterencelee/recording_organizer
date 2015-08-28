#!/bin/sh

# usage:  probe-reboot.sh <file to check> <email address>
# use complicated cron setup to check
# 20:01  probe-reboot.sh %Y-%m-%d-channel-2000-2030-test	    # check as soon as recording starts
# 20:55  probe-reboot.sh %Y-%m-%d-channel-2000-2030-test <email>    # set to check near end with time enough for one last reboot

# require
DU="du -c"
DATE="date"
SED="sed"

# use an external program like cron to check if a recording started
# check if recording file size has changed continuously for the monitoring period

FILE=`$DATE +$1`
OLD_SIZE=`eval "$DU $FILE" | $SED '$!d' | $SED 's/\([0-9]\+\).*/\1/g'`
sleep 60
NEW_SIZE=`eval "$DU $FILE" | $SED '$!d' | $SED 's/\([0-9]\+\).*/\1/g'`

[ $OLD_SIZE -eq $NEW_SIZE ] && reboot
# check if recording failed, if failed, email and reboot system
# what is considered a failed recording? and how many failed test? scoring system? complicated

# no recording
# recording file is too small
# error message in system log

#email

#reboot
