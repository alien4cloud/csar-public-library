#!/usr/bin/env bash

#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set

source ${scripts}/java_utils.sh


if [[ "${JAVA_HOME}" == "/opt/"* ]]
then
    # Java was installed from a downloaded java archive, so always remove it.
    log info "Remove JAVA_HOME directory (${JAVA_HOME})"
    sudo rm -rf ${JAVA_HOME}
else
    # Uninstall Java packages only if it is no longer used by anyone
    subtract_a_java_install ${JAVA_VERSION}
    if [[ $(is_java_not_used ${JAVA_VERSION}) -eq 0 ]]
    then
        log info "Uninstall JAVA ${JAVA_VERSION} packages"
        os_distribution="$(get_os_distribution)"
        case "${os_distribution}" in
            "ubuntu")
                sudo apt-get remove openjdk-${JAVA_VERSION}-jre openjdk-${JAVA_VERSION}-jre-headless openjdk-${JAVA_VERSION}-jdk oracle-java${JAVA_VERSION}-installer oracle-java${JAVA_VERSION}-set-default
                ;;
            "centos" | "redhat" | "fedora")
                sudo yum remove -y java-1.${JAVA_VERSION}.0-openjdk java-1.${JAVA_VERSION}.0-openjdk-headless java-1.${JAVA_VERSION}.0-openjdk-devel
                ;;
            *)
                error_exit "Unsupported Operating System: ${os_distribution}"
                ;;
        esac
    else
        log info "Do not uninstall JAVA ${JAVA_VERSION} packages because there are still used by someone else"
    fi
fi


log end