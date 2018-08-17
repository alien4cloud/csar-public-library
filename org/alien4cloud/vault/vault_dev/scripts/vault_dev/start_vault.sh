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
  printf "%s\n" "Service not running, we start Vault in dev mode."
  nohup bash -c 'vault server -dev & echo \$! > sudo ${PIDFILE}' >> /dev/null 2>&1 &
fi
