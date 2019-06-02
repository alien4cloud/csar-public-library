#!/usr/local/env bash

set -e

echo "Getting status for job ${TOSCA_JOB_ID}"

if [[ -z "${TOSCA_JOB_ID}" ]] ; then
    >&2 echo "Missing TOSCA_JOB_ID"
    exit 1
fi

status=$(curl --noproxy "${SPARK_IP}" -s -f --show-error "http://${SPARK_IP}:${SPARK_REST_PORT}/v1/submissions/status/${TOSCA_JOB_ID}")
status=$(echo ${status} | grep "\"driverState\"" | sed -e 's/^.*driverState" *: *"\([^"]*\)".*$/\1/g')

echo "Retrieved status for job ${TOSCA_JOB_ID}: ${status}"

case $status in
"FAILED" | "ERROR")
    export TOSCA_JOB_STATUS="FAILED"
    ;;
"FINISHED")
    export TOSCA_JOB_STATUS="COMPLETED"
    ;;
"RUNNING")
    export TOSCA_JOB_STATUS="RUNNING"
    ;;
"WAITING")
    export TOSCA_JOB_STATUS="QUEUED"
    ;;
*)
    >&2 echo "Unexpected status ${status} for job ${TOSCA_JOB_ID}"
esac
