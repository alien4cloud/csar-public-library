#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


# Installation of packages on CentOS/Ubuntu OS distributions

# Note: Do not use ${utils_scripts} variable to not force the name of the artifact of the utils scripts
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${scriptDir}/utils.sh

os_distribution="$(get_os_distribution)"

case "${os_distribution}" in
    "centos")
        bash ${scriptDir}/yum-install-components.sh $@
        ;;
    "ubuntu")
        bash ${scriptDir}/apt-install-components.sh $@
        ;;
    *)
        error_exit  "Unsupported Operating System: ${os_distribution}"
        ;;
esac
