#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

if isServiceInstalled; then
    log info "Component '${NODE}' already installed"
    exit 0
fi

tmpdir=$(mktemp -d)
install_dir=${HOME}/${NODE}
mkdir -p ${install_dir}

tar xzf ${beat_bin} -C ${tmpdir}

find ${tmpdir} -type f -exec mv -f {} ${install_dir} \;

rm -fr ${tmpdir}

cp ${beat_config} ${install_dir}

# Set environment variable used for systemd
SERVICE_NAME=$(basename -s .yml ${beat_config})
log info "SERVICE_NAME=${SERVICE_NAME}"
DEBUG_ARGS=""
if [[ "${DEBUG_LOGS}" == "true" ]]; then
    DEBUG_ARGS="-e -d '*'"
fi

# Setup systemd service
sudo cp ${scripts}/systemd/xbeat.service /etc/systemd/system/${SERVICE_NAME}.service
sudo sed -i -e "s@{{BEAT_HOME}}@${install_dir}@g" -e "s/{{SERVICE_NAME}}/${SERVICE_NAME}/g" -e "s/{{DEBUG_ARGS}}/${DEBUG_ARGS}/g" /etc/systemd/system/${SERVICE_NAME}.service
sudo sed -i -e "s@{{http_proxy}}@${http_proxy}@g" -e "s@{{https_proxy}}@${https_proxy}@g" -e "s@{{HTTP_PROXY}}@${HTTP_PROXY}@g" -e "s@{{HTTPS_PROXY}}@${HTTPS_PROXY}@g" /etc/systemd/system/${SERVICE_NAME}.service
sudo systemctl daemon-reload
#sudo systemctl enable ${SERVICE_NAME}.service

setServiceInstalled
log end
