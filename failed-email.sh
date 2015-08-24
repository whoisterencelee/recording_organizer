#!/bin/sh

# check if recording failed, if failed, email and reboot system
# what is considered a failed recording?
# and how many failed test?
# scoring system? complicated

# no recording
# recording file is too small
# error message in system log

TODAY=`date +%Y-%m-%d-Pearl-%H%M-0000-test1.ts`
TODAY=`date +%Y-%m-%d-*-$1.ts`

#email

#reboot
