#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#



. ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set

function install_from_url () {
    YSTIA_JAVA_HOME=${1}
    sudo mkdir -p ${YSTIA_JAVA_HOME}
    java_zip="java-$$.zip"
    sudo wget --header "Cookie: oraclelicense=accept-securebackup-cookie" -O "${YSTIA_JAVA_HOME}/${java_zip}" "${JAVA_DOWNLOAD_URL}"

    case "${JAVA_DOWNLOAD_URL}" in
        *.zip)
            sudo unzip "${YSTIA_JAVA_HOME}/${java_zip}" -d ${YSTIA_JAVA_HOME}
            sudo rm "${YSTIA_JAVA_HOME}/${java_zip}"
            sudo mv ${YSTIA_JAVA_HOME}/*/* ${YSTIA_JAVA_HOME}
            ;;
        *.tar)
            sudo tar xf "${YSTIA_JAVA_HOME}/${java_zip}" --strip-components=1 --directory=${YSTIA_JAVA_HOME}
            sudo rm "${YSTIA_JAVA_HOME}/${java_zip}"
            ;;
        *.tar.gz | *.tgz)
            sudo tar xzf "${YSTIA_JAVA_HOME}/${java_zip}" --strip-components=1 --directory=${YSTIA_JAVA_HOME}
            sudo rm "${YSTIA_JAVA_HOME}/${java_zip}"
            ;;
        *.tar.bz2)
            sudo tar xjf "${YSTIA_JAVA_HOME}/${java_zip}" --strip-components=1 --directory=${YSTIA_JAVA_HOME}
            sudo rm "${YSTIA_JAVA_HOME}/${java_zip}"
            ;;
    esac
}

function ubuntu_install_openjdk () {
    if [[ "${JAVA_IS_JRE}" == "true" ]]
    then
        packages="${packages}-jre"
        if [[ "${JAVA_IS_HEADLESS}" == "true" ]]
        then
            packages="${packages}-headless"
        fi
    else
        packages="${packages}-jdk"
    fi
    bash ${utils_scripts}/apt-install-components.sh ${packages} || {
        error_exit "Failed to install java packages: \"${packages}\" using apt-get"
    }

    YSTIA_JAVA_HOME="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-$(dpkg --print-architecture)"
    if [[ "${JAVA_IS_JRE}" == "true" ]]
    then
        YSTIA_JAVA_HOME="${YSTIA_JAVA_HOME}/jre"
    fi
    export YSTIA_JAVA_HOME=${YSTIA_JAVA_HOME}
}

function ubuntu_install_oracle_jdk () {

    echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

    sudo -E add-apt-repository  -y ppa:webupd8team/java
    touch /tmp/forceaptgetupdate
    packages="oracle-java${JAVA_VERSION}-installer oracle-java${JAVA_VERSION}-set-default"
    bash ${utils_scripts}/apt-install-components.sh ${packages} || {
        error_exit "Failed to install java packages: \"${packages}\" using apt-get"
    }
    YSTIA_JAVA_HOME="/usr/lib/jvm/java-${JAVA_VERSION}-oracle"
    if [[ "${JAVA_IS_JRE}" == "true" ]]
    then
        YSTIA_JAVA_HOME="${YSTIA_JAVA_HOME}/jre"
    fi
    export YSTIA_JAVA_HOME=${YSTIA_JAVA_HOME}
}

# If java component already installed, nothing to do
if is_java_already_installed "${NODE}"
then
    echo "Java component '${NODE}' already installed"
    exit
fi

os_distribution="$(get_os_distribution)"
YSTIA_JAVA_HOME=""
case "${os_distribution}" in
    "ubuntu")
        if [[ ! -z "${JAVA_DOWNLOAD_URL}" ]] && [[ "${JAVA_DOWNLOAD_URL}" != "null" ]]
        then
            bash ${utils_scripts}/apt-install-components.sh "wget" "unzip" "tar" "bzip2" "gzip" || {
                error_exit "Failed to install required support packages using apt-get"
            }
            YSTIA_JAVA_HOME=/opt/${NODE}
            install_from_url "${YSTIA_JAVA_HOME}"
        else
            packages="openjdk-${JAVA_VERSION}"
            if [[ "$(apt-cache pkgnames ${packages} | wc -l)" != "0" ]]; then
                ubuntu_install_openjdk
            else
                ubuntu_install_oracle_jdk
            fi
        fi
        ;;

    "centos" | "redhat" | "fedora")
        if [[ ! -z "${JAVA_DOWNLOAD_URL}" ]] && [[ "${JAVA_DOWNLOAD_URL}" != "null" ]]
        then
            sudo yum install -y "wget" "unzip" "tar" "bzip2" "gzip" || {
                error_exit "Failed to install required support packages using yum"
            }
            YSTIA_JAVA_HOME=/opt/${NODE}
            install_from_url "${YSTIA_JAVA_HOME}"
        else
            packages="java-1.${JAVA_VERSION}.0-openjdk"
            if (( "${JAVA_VERSION}" >= "8" )) && [[ "${JAVA_IS_JRE}" == "true" ]] && [[ "${JAVA_IS_HEADLESS}" == "true" ]]
            then
                packages="${packages}-headless"
            fi
            if [[ "${JAVA_IS_JRE}" != "true" ]]
            then
               packages="${packages}-devel"
            fi
            sudo yum install -y ${packages}   || {
                error_exit "Failed to install java packages: \"${packages}\" using yum"
            }
            if [[ "${JAVA_IS_JRE}" == "true" ]]
            then
                YSTIA_JAVA_HOME="/usr/lib/jvm/jre-1.${JAVA_VERSION}.0-openjdk"
            else
                YSTIA_JAVA_HOME="/usr/lib/jvm/java-1.${JAVA_VERSION}.0-openjdk"
            fi
            if [[ "${os_distribution}" != "centos" ]]
            then
                YSTIA_JAVA_HOME="${YSTIA_JAVA_HOME}.$(uname -i)"
            fi
        fi
        ;;

    *)
        error_exit  "Unsupported Operating System: ${os_distribution}"
        ;;
esac

log info "JAVA_HOME is ${YSTIA_JAVA_HOME}"
export YSTIA_JAVA_HOME
log end
