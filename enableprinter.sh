#! /bin/bash

debug=0

if [ $# -ne 1 ]
then
  echo "Usage: enableprinter.sh <printer name>"
  exit
fi

lpqResult=`lpq $1 | grep "is ready" | wc -l`
if [ $lpqResult -eq 1 ]
then
  if [ $debug -ne 0 ]
  then
    echo "found $1 ready...exiting."
  fi
  exit
fi

if [ $debug -ne 0 ]
then
  echo "found $1 not ready...attempting to enable."
fi
cupsenable $1

lpqResult=`lpq $1 | grep "is ready" | wc -l`
if [ $lpqResult -eq 1 ]
then
  if [ $debug -ne 0 ]
  then
    echo "found $1 ready...exiting."
  fi
else
  echo "Error: unable to enable $1...exiting."
fi
exit
