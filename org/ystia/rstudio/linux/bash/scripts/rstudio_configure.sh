#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#



source ${utils_scripts}/utils.sh
source ${scripts}/rstudio-service.properties
log begin

ensure_home_var_is_set

r_script_name="/tmp/get_home-$$.R"
echo "R.home()" > ${r_script_name}
r_home=$(Rscript --vanilla ${r_script_name} | grep '[1]' | sed -e 's@.*"\([^"]\+\).*@\1@g')
rm ${r_script_name}

# Create user for using RStudio from properties
# If RStudio is connected to a block storage, put on it the user home directory
log info  ">>>> RStudio user creation"
UHOME_DIR=""
if [[ -e "${YSTIA_DIR}/.${NODE}-blockstorageFlag" ]]; then
    source ${YSTIA_DIR}/${NODE}-service.env
    log info ">>>> RStudio component '${NODE}' connected to a block storage mounted on '${PATH_FS}'"
    UHOME_DIR="${PATH_FS}/${LOGIN}"
fi
if [[ -n "${UHOME_DIR}" ]]; then
    OPT_UHOME_DIR="--home ${UHOME_DIR}"
fi
sudo useradd -m ${LOGIN} ${OPT_UHOME_DIR}
echo "${LOGIN}:${PASSWORD}" | sudo chpasswd
if [[ -n "${UHOME_DIR}" ]]; then
    sudo chown -R ${LOGIN}:${LOGIN} ${UHOME_DIR}
fi


# Proxy configuration for RStudio
log info ">>>> RStudio proxy configuration"
if [[ "${PROXY}" == "None" ]]; then
    cat | sudo tee -a ${r_home}/etc/Renviron ${r_home}/etc/Renviron.site > /dev/null <<EOF
unset http_proxy
unset https_proxy
unset ftp_proxy
no_proxy='*'
EOF
else
    if [[ -n "${PROXY}" ]]; then
        cat | sudo tee -a ${r_home}/etc/Renviron ${r_home}/etc/Renviron.site > /dev/null <<EOF
http_proxy='${PROXY}'
https_proxy='${PROXY}'
ftp_proxy='${PROXY}'
EOF
    else
        if [[ -n "${http_proxy}" ]]; then
           echo "http_proxy='${http_proxy}'" | sudo tee -a ${r_home}/etc/Renviron ${r_home}/etc/Renviron.site > /dev/null
        fi
        if [[ -n "${https_proxy}" ]]; then
           echo "https_proxy='${https_proxy}'" | sudo tee -a ${r_home}/etc/Renviron ${r_home}/etc/Renviron.site > /dev/null
        fi
        if [[ -n "${ftp_proxy}" ]]; then
           echo "ftp_proxy='${ftp_proxy}'" | sudo tee -a ${r_home}/etc/Renviron ${r_home}/etc/Renviron.site > /dev/null
        fi
        if [[ -n "${no_proxy}" ]]; then
           echo "no_proxy='${no_proxy}'" | sudo tee -a ${r_home}/etc/Renviron ${r_home}/etc/Renviron.site > /dev/null
        fi
    fi
fi

if [[ -z "${CRAN_MIRROR}" ]] || [[ "${CRAN_MIRROR}" == "DEFAULT" ]] || [[ "${CRAN_MIRROR}" == "null" ]]; then
    CRAN_MIRROR=${R_CRAN_DEFAUT_MIRROR}
fi

# Repo configuration for R and download method
echo ">>>> RStudio repo configuration"
cat | sudo tee -a ${r_home}/etc/Rprofile.site > /dev/null <<EOL
local({r <- getOption("repos")
       r["CRAN"] <- "${CRAN_MIRROR}"
       options(repos=r)
})
options(download.file.method = "wget")
EOL

log end "RStudio configured !"
