#!/usr/bin/env bash


source ${utils_scripts}/utils.sh
source ${scripts}/rstudio-service.properties
log begin

# To set variables for the proxy
ensure_home_var_is_set

if isServiceInstalled; then
    log info "RStudio component '${NODE}' already installed"
    exit 0
fi

bash ${utils_scripts}/install-components.sh "wget" || error_exit "ERROR: Failed to install wget"

log info "Installing RStudio"
log info "Environment variables : source is ${scripts} - home is ${HOME}"

os_distribution="$(get_os_distribution)"
case "${os_distribution}" in
    "ubuntu")
        # Add repository to download R
        echo -e "deb https://cran.rstudio.com/bin/linux/ubuntu trusty/" | sudo tee --append "/etc/apt/sources.list.d/rstudio-dep.list"

        sudo -E apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
        sudo touch /tmp/forceaptgetupdate
    ;;
    "centos")
        if [[ "$(yum repolist | grep -c epel)" == "0" ]]; then
            bash ${utils_scripts}/yum-install-components.sh epel-release
        fi
    ;;
esac

# installing R
declare -A packages_names=( ["centos"]="R-core R-core-devel git" ["ubuntu"]="r-base r-base-dev git" )
log info "Installing R base and dependencies ..."
os_distribution="$(get_os_distribution)"
bash ${utils_scripts}/install-components.sh ${packages_names["${os_distribution}"]} || error_exit "ERROR: Failed to install R Base (install-components.sh ${packages_names["${os_distribution}"]} problem) !!!"

# download & install RStudio
if [[ -z "${REPOSITORY}" ]] || [[ "${REPOSITORY}" == "DEFAULT" ]] || [[ "${REPOSITORY}" == "null" ]]; then
    REPOSITORY=${R_DEFAULT_REPO_URL}
fi

case "${os_distribution}" in
    "ubuntu")
        binName="rstudio-server-${RSTUDIO_VERSION}-amd64.deb"
    ;;
    "centos")
        binName="rstudio-server-rhel-${RSTUDIO_VERSION}-x86_64.rpm"
    ;;
esac

downloadPath="${REPOSITORY}/${binName}"

wget -O ${HOME}/${binName} "${downloadPath}"

case "${os_distribution}" in 
    "ubuntu")
        sudo dpkg -i ${HOME}/${binName}
        sudo apt-get install -y git-core &&
        sleep 12
        sudo apt-get install -y subversion

    ;;
    "centos")
        sudo yum install -y --nogpgcheck ${HOME}/${binName}
        sudo yum install -y git-core &&
        sleep 12
        sudo yum install -y subversion
    ;;
esac

# stop RStudio that should have been started by yum.
sudo rstudio-server stop || log warning "RStudio could not be stopped"

setServiceInstalled
log end "RStudio ${RSTUDIO_VERSION} installed !"
