#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set

property_name="c.NotebookApp.notebook_dir"
property_value="${path_fs}"

if [[ ! -z "${property_value}" ]] && [[ "${property_value}" != "null" ]]
then
    if [[ $(grep -c -E "^\s*${property_name}=" $HOME/.jupyter/jupyter_notebook_config.py) -gt 1 ]]
    then
        sed -i.bak -e "s/^\s*${property_name}=/#${property_name}=/g" $HOME/.jupyter/jupyter_notebook_config.py
        echo "${property_name}=\"${property_value}\"" >> $HOME/.jupyter/jupyter_notebook_config.py
    else
        # replace only the first match
        sed -i -e "0,/^.*${property_name}=.*$/s##${property_name}=\"${property_value}\"#" $HOME/.jupyter/jupyter_notebook_config.py
    fi
fi

log end "Connect Jupyter component '${SOURCE_NODE}' to a volume '${TARGET_NODE}' using path '${path_fs}' to store notebooks"