!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set

log info "Installing DummyLogsGenerator..."
INSTALL_DIR=${HOME}/${NODE}
mkdir -p ${INSTALL_DIR}
cp ${scripts}/dummylogs_start.sh ${INSTALL_DIR}
log info "DummyLogsGenerator installed under ${INSTALL_DIR}"

log end
