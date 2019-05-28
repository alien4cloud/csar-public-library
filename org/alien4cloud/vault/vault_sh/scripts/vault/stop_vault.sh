#!/bin/bash -e

PIDFILE=/var/run/vault.pid
if [ -f $PIDFILE ]; then
  PID=`cat $PIDFILE`
  if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
    printf "%s\n" "Process dead but pid file exists, removing it"
  else
    echo "Stopping vault server"
    sudo kill -TERM $PID
  fi
  sudo /bin/rm $PIDFILE
fi
