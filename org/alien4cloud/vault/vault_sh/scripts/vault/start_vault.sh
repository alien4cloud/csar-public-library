#!/bin/bash -e
PIDFILE=/var/run/vault.pid

if [ -f $PIDFILE ]; then
  PID=`cat $PIDFILE`
  if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
    printf "%s\n" "Process dead but pidfile exists"
  else
    echo "Running"
  fi
else
  printf "%s\n" "Service not running"
  ./usr/bin/vault server -dev & echo \$! > ${PIDFILE}
fi
