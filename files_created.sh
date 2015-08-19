#!/bin/sh
# find newest file
# use with cron and/or post process
# best to use in post process and then set it to run once an hour + 1 min in cron (worst case miss by an hour)
# there is a chance the touch .last_check happens the same time the touch occurs

# requires:
LS="ls -tAr"
SED="sed"
TOUCH="touch"

{ $LS $1; $TOUCH $1/.last_check; } | $SED '1,/.last_check/d'
