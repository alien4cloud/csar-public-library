#!/usr/local/env bash

set -e

if [[ -z "$(which jq)" ]] ; then
    if [[ -n "$(which yum)" ]] ; then
        sudo yum install -q -y jq
    elif [[ -n "$(which apt)" ]] ; then
        sudo apt install -y jq
    else 
        >&2 echo "jq software is missing and we can't install it"
    fi
fi

sub=$(echo ${SUBMIT_PROPS} | \
    jq 'with_entries( select( .value != "" ))' | \
    jq 'with_entries( if .key | contains("_") then .key |= sub("_";".") else . end | .key |= "spark." + .)' | \
    jq ". + {\"spark.submit.deployMode\": \"cluster\", \"spark.master\": \"spark://${SPARK_IP}:${SPARK_REST_PORT}\"}" | \
    jq "{\"mainClass\": \"${MAIN_CLASS}\", \"clientSparkVersion\": \"2.4.3\",  \"environmentVariables\": {\"SPARK_ENV_LOADED\": \"1\"}, \"action\": \"CreateSubmissionRequest\", \"sparkProperties\" : .}")

if [[ -n "${APP_ARGS}" ]] ; then
    sub=$(echo ${sub} | jq ". + {\"appArgs\": ${APP_ARGS} }")
fi


if [[ -n "${JAR_URL}" ]] ; then
    if [[ -z "${JAR_INSTALL_PATH}" ]] ; then
        JAR_INSTALL_PATH=${JAR_URL}
    else
        curl -f --show-error -s "${JAR_DOWNLOAD}" --output "${JAR_INSTALL_PATH}"
    fi

    sub=$(echo ${sub} | jq ". + {\"appResource\": \"${JAR_INSTALL_PATH}\" } ")
    jars=$(echo ${sub} | jq -r '."sparkProperties"."spark.jars"')
    if [[ "${jars}" == "null" ]] ; then
        jars="${JAR_INSTALL_PATH}"
    else
        jars="${jars},${JAR_INSTALL_PATH}"
    fi
    sub=$(echo ${sub} | jq ". * {\"appResource\": \"${JAR_INSTALL_PATH}\", \"sparkProperties\" : { \"spark.jars\": \"${jars}\" } } ")
fi

echo "Submitting resource : ${sub}"

tmp=$(mktemp)
echo "${sub}" > ${tmp}

sub_result=$(curl --noproxy "${SPARK_IP}" -f --show-error -X POST "http://${SPARK_IP}:${SPARK_REST_PORT}/v1/submissions/create" --header "Content-Type:application/json;charset=UTF-8" --data @"${tmp}")
echo "got response from Spark:"
echo "${sub_result}"
TOSCA_JOB_ID=$(echo ${sub_result} | grep "\"submissionId\"" | sed -e 's/^.*submissionId" *: *"\([^"]*\)".*$/\1/g')
export TOSCA_JOB_ID
echo "Spark Job submitted with id: ${TOSCA_JOB_ID}"
