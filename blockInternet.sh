#!/bin/bash

# Script to prevent children from staying up all night playing games on the internet
# when they should be sleeping on a school night :-/

# This script will turn off a network interface at a predefined time and turn it
# back on at a later time (either later in the day or the next day).
#
#	if killTime < startTime, turn on interface later in the same day it was killed.
#	if killTime > startTime, turn on interface the next day.
#
# The script can be run as a service or started as a daemon. This will prevent a
# reboot of the computer from turning the internet back on.

killTime=2300		# Time to turn off internet.
startTime=0330		# Time to turn on internet.
sleepTime=60		# Sleep time between checks.
state=1			# Initial state (internet is up).
interface=p8p1		# Interface to manipulate.

# Strip leading zeroes from time, to prevent bash from thinking they're octal.

killTime=$(echo $killTime | sed 's/^0*//')
startTime=$(echo $startTime | sed 's/^0*//')

while true
do
  theDate=`date`
  rawTime=`date +%H%M`
  theTime=$(echo $rawTime | sed 's/^0*//')

# echo "killTime  = $killTime"
# echo "startTime = $startTime"
# echo "theTime   = $theTime"

  # There are two cases to cover:
  #    Case 1 - killTime > startTime, turn off, then turn on the next day.
  #    Case 2 - killTime < startTime, turn off, then turn on later in the day.

  if [[ $killTime -gt $startTime ]]
  then

    # Handle the case where the killTime > startTime. This is the case where
    # we want the internet turned off, and it will turn on sometime the next day.

    if [[ $theTime -ge $killTime ]]
    then
      if [[ $state -eq 1 ]]
      then
        echo "$theDate : ifconfig $interface down, transition 1"
        ifconfig $interface down
        state=0
      fi
    fi

    if [[ $theTime -lt $startTime ]]
    then
      if [[ $state -eq 1 ]]
      then
        echo "$theDate : ifconfig $interface down, transition 2"
        ifconfig $interface down
        state=0
      fi
    fi

    if [[ $theTime -ge $startTime ]] && [[ $theTime -lt $killTime ]]
    then
      if [[ $state -eq 0 ]]
      then
        echo "$theDate : ifup $interface, transition 3"
        ifup $interface
        state=1
      fi
    fi

  else

    # Handle the case where the killTime < startTime. This is the case where
    # we want the internet turned off, and it will turn on later the same day.

    if [[ $theTime -ge $killTime ]]
    then
      if [[ $state -eq 1 ]]
      then
        echo "$theDate : ifconfig $interface down, transition 4"
        ifconfig $interface down
        state=0
      fi
    fi

    if [[ $theTime -ge $startTime ]]
    then
      if [[ $state -eq 0 ]]
      then
        echo "$theDate : ifup $interface, transition 5"
        ifup $interface
        state=1
      fi
    fi

  fi
  sleep $sleepTime
done
