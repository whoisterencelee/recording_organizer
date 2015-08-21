#!/bin/sh
# find newly created/modified file, result is from newest to oldest

# use with cron and/or post process
# best to use in post process and then set it to run once an hour + 1 min in cron (worst case miss by an hour)
# there is a chance the touch .last_check happens the same time the touch occurs

# requires:
LS="ls -tA"
SED="sed"
TOUCH="touch"

[ -z $1 ] && echo "Usage: ./files_created.sh <directory to watch for new file>" &&  exit 1;

{ $LS $1; $TOUCH $1/.last_check; } | $SED '/.last_check/,$d'

# to get oldest to newest, comment out above line and uncomment below, and use ls -tAr
# and need to create .last_check file manually otherwise sed will return nothing on first run
# { $LS $1; $TOUCH $1/.last_check; } | $SED '0,/.last_check/d'
# the default should be faster going from newest to oldest as .last_check normally appears near the top
# whereas with oldest to newest .last_check is near the bottom
