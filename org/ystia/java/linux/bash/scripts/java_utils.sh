#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

#
# Manage the java_install.history file which contains the number of time java packages is installed
# The syntax of a line is:  <JAVA_VERSION>:<INSTALLATION_NUMBER>
#

LOCK_NAME=yforge_java
HISTORY_JAVA_INSTALL=${YSTIA_DIR}/java_install.history


add_a_java_install() {
# For the first add, set the NB installation to 2 if JALLREADY_INSTALL, 1 otherwise
# For the next add, set the NB installation to NB+1
    JVERSION=$1
    JALLREADY_INSTALL=$2

    log info "Add an installation for Java version ${JVERSION}"
    lock ${LOCK_NAME}

    [[ ! -r ${HISTORY_JAVA_INSTALL} ]] && touch ${HISTORY_JAVA_INSTALL}

    if ! grep "^${JVERSION}:" ${HISTORY_JAVA_INSTALL} >/dev/null
    then
        NB_INIT=1
        [[ ${JALLREADY_INSTALL} -eq 0 ]] && NB_INIT=2
        echo "${JVERSION}:${NB_INIT}" >>${HISTORY_JAVA_INSTALL}
    else
        NB=$(grep "^${JVERSION}:" ${HISTORY_JAVA_INSTALL}| cut -d: -f 2)
        if [[ $NB -le 0 ]]
        then
            NB=1
            [[ ${JALLREADY_INSTALL} -eq 0 ]] && NB=2
        else
            NB=$(expr $NB + 1) || true
        fi
        sed -i -e "s/^${JVERSION}:.*/${JVERSION}:${NB}/" ${HISTORY_JAVA_INSTALL}
    fi
    unlock ${LOCK_NAME}
}

subtract_a_java_install() {
    JVERSION=$1

    log info "Substract an installation for Java version ${JVERSION}"
    lock ${LOCK_NAME}

    if [[ ! -r ${HISTORY_JAVA_INSTALL} ]]
    then
        log info "WARNING subtract_a_java_install: ${HISTORY_JAVA_INSTALL} file not exist"
        unlock ${LOCK_NAME}
        return
    fi

    if ! grep "^${JVERSION}:" ${HISTORY_JAVA_INSTALL} >/dev/null
    then
        log info "WARNING subtract_a_java_install: Version ${JVERSION} not exist in ${HISTORY_JAVA_INSTALL} file"
        unlock ${LOCK_NAME}
        return
    fi

    NB=$(grep "^${JVERSION}:" ${HISTORY_JAVA_INSTALL}| cut -d: -f 2)
    NB=$(expr ${NB} - 1) || true
    sed -i -e "s/^${JVERSION}:.*/${JVERSION}:${NB}/" ${HISTORY_JAVA_INSTALL}
    unlock ${LOCK_NAME}
}

# Echo 0 if not used or Echo 1 if used
is_java_not_used() {
    JVERSION=$1
    lock ${LOCK_NAME}

    if [[ ! -r ${HISTORY_JAVA_INSTALL} ]]
    then
        unlock ${LOCK_NAME}
        echo "0"
        return
    fi
    grep "^${JVERSION}:" ${HISTORY_JAVA_INSTALL} >/dev/null
    if ! grep "^${JVERSION}:" ${HISTORY_JAVA_INSTALL} >/dev/null
    then
        unlock ${LOCK_NAME}
        echo "0"
        return
    fi

    NB=$(grep "^${JVERSION}:" ${HISTORY_JAVA_INSTALL}| cut -d: -f 2)
    if [[ $NB -le 0 ]]
    then
        unlock ${LOCK_NAME}
        echo "0"
        return
    fi

    unlock ${LOCK_NAME}
    echo "1"
    return
}
