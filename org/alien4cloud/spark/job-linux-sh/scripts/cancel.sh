#!/usr/local/env bash

set -e

if [[ -z "${TOSCA_JOB_ID}" ]] ; then
    >&2 echo "Missing TOSCA_JOB_ID"
    exit 1
fi

curl --noproxy "${SPARK_IP}" -s -f --show-error -X POST "http://${SPARK_IP}:${SPARK_REST_PORT}/v1/submissions/kill/${TOSCA_JOB_ID}"
