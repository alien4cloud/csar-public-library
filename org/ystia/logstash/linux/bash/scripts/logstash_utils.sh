#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

# Replace Logstash configuration file with a new one
# params:
#   1- file to replace (ex. $LOGSTASH_HOME/conf/1-1_logstash_inputs.conf)
#   2- resource type to configure (ex. input, output or filter)
#   3- url to download the new file
# returns 0 if the file correctly downloaded and installed in the conf directory
replace_conf_file() {
    path=$1
    type=$2
    url=$3
    if curl -sS $url >/tmp/curlout 2>/tmp/curlerr
    then
        if grep $type  </tmp/curlout >/dev/null
        then
            if config_file_test /tmp/curlout
            then
                log info "updating $path"
		        cp /tmp/curlout $path
		        log info "configuration successfully updated"
		    else
                log info "new configuration file is not valid"
		        return 1
		    fi
        else
            log info "$url is not a $type configuration"
            return 1
        fi
    else
        log info `cat /tmp/curlerr`
        return 1
    fi
    return 0
}

# Replace the value of a property in a Logstash configuration file
# params:
#   1- file where the substitution will be done (ex. $LOGSTASH_HOME/conf/1-1_logstash_inputs.conf)
#   2- name of the property to modify
#   3- new value of the property
# returns 0 if the file is correctly modified
replace_conf_value() {
    path=$1
    key=$2
    new_value=$3

    log info "replace the property $key with the value $new_value in file $path"

    # check if the property exists
    if [[ "$(grep -c "${key} =>" "${path}")" != "0" ]]; then

        sed -i -e '/'"${key}"' =>/s/=>.*/=> '"${new_value}"'/g' ${path}

    else

        sed -i -e '/    }/ i \
        '"${key}"' => '"${new_value}"'' ${path}

    fi

    return 0
}

# Add a property in a Logstash configuration file
# params:
#   1- file where the substitution will be done (ex. $LOGSTASH_HOME/conf/1-1_logstash_inputs.conf)
#   2- name of the property to add
#   3- value of the property to add
# returns 0 if the file is correctly modified
add_conf_property() {
    path=$1
    key=$2
    value=$3

    log info "add the property $key with the value $value in file $path"

    sed -i -e '/    }/ i \
        '"${key}"' => '"${value}"'' ${path}

    return 0
}

# Delete a property in a Logstash configuration file
# params:
#   1- file where the substitution will be done (ex. $LOGSTASH_HOME/conf/1-1_logstash_inputs.conf)
#   2- name of the property to delete
# returns 0 if the file is correctly modified
del_conf_property() {
    path=$1
    key=$2

    log info "delete the property $key in file $path"

    sed -i -e '/'"${key}"'/d' ${path}

    return 0
}

# Add a value in an array property in a Logstash configuration file
# params:
#   1- file where the substitution will be done (ex. $LOGSTASH_HOME/conf/1-1_logstash_inputs.conf)
#   2- name of the property to complete
#   3- value to add
# returns 0 if the file is correctly modified
add_values_in_array_property() {
    path=$1
    key=$2
    properties_to_add=$3

    log info "Add ${properties_to_add[@]} in an property ${key} in file ${path}"

    # check if the property is an array property
    if [[ "$(grep -c "${key} => \[" "${path}")" != "0" ]]; then

        # get property values
        properties=`sed -n -e '/'"${key}"' =>/s/'.*"${key}"' =>//p' ${path}`

        # convert the property values (["value1", "value2"] into array

        # remove potential blanks
        properties="$(echo -e "${properties}" | tr -d '[[:blank:]]')"
        # remove brackets
        properties=${properties#"["}
        properties=${properties%"]"}
        # tokenize
        IFS=', ' read -r -a properties_array <<< "$properties"

        log debug "existent property values converted in array : ${properties_array[@]}"

        # convert the properties to add into an array

        # remove potential blanks
        properties_to_add="$(echo -e "${properties_to_add}" | tr -d '[[:blank:]]')"
        # remove brackets
        properties_to_add=${properties_to_add#"["}
        properties_to_add=${properties_to_add%"]"}
        IFS=', ' read -r -a properties_to_add_array <<< "$properties_to_add"

        log debug "property to add values converted in array : ${properties_to_add_array[@]}"

        #concat arrays
        declare -a concat_arrays=(${properties_array[@]} ${properties_to_add_array[@]})
        # remove duplicates
        array_result=$(echo "${concat_arrays[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

        log debug "new property values: ${array_result[@]}"

        # convert array to string
        result="["

        for keyword in ${array_result[@]}; do
            result+=$keyword,
        done
        result=${result%","}
        result+="]"

        # inject new value in conf file
        replace_conf_value ${path} ${key} ${result}

    else
        log info "No property ${key} found in ${path}, add it and set its value with ${properties_to_add}"
        replace_conf_value ${path} ${key} "${properties_to_add}"
    fi

    return 0
}

# Remove a value in an array property in a Logstash configuration file
# params:
#   1- file where the substitution will be done (ex. $LOGSTASH_HOME/conf/1-1_logstash_inputs.conf)
#   2- name of the property to complete
#   3- value to remove
# returns 0 if the file is correctly modified
remove_values_in_array_property() {

    path=$1
    key=$2
    properties_to_remove=$3

    log info "Remove ${properties_to_add[@]} in an property ${key} in file ${path}"

    # check if the property is an array property
    if [[ "$(grep -c "${key} => \[" "${path}")" != "0" ]]; then

        # get property values
        properties=`sed -n -e '/'"${key}"' =>/s/'.*"${key}"' =>//p' ${path}`

        # convert the property values (["value1", "value2"] into array

        # remove potential blanks
        properties="$(echo -e "${properties}" | tr -d '[[:blank:]]')"
        # remove brackets
        properties=${properties#"["}
        properties=${properties%"]"}
        # tokenize
        IFS=', ' read -r -a properties_array <<< "$properties"

        log debug "existent property values converted in array : ${properties_array[@]}"

        # convert the properties to remove into an array

        # remove potential blanks
        properties_to_remove="$(echo -e "${properties_to_remove}" | tr -d '[[:blank:]]')"
        # remove brackets
        properties_to_remove=${properties_to_remove#"["}
        properties_to_remove=${properties_to_remove%"]"}
        IFS=', ' read -r -a properties_to_remove_array <<< "$properties_to_remove"

        log debug "property to remove values converted in array : ${properties_to_remove_array[@]}"

        # substract array
        index=0
        for element in ${properties_array[@]}; do
            if [[ " ${properties_to_remove_array[*]} " == *" $element "* ]]; then
                unset properties_array[$index]
            fi
            let index++
        done

        log debug "new property values: ${properties_array[@]}"

        # convert array to string
        result="["

        for keyword in ${properties_array[@]}; do
            result+=$keyword,
        done
        result=${result%","}
        result+="]"

        # inject new value in conf file
        replace_conf_value ${path} ${key} ${result}

    else
        log info "No property ${key} found in ${path}"

    fi

    return 0
}

# Check Logstash configuration
# params:
#   1- logstash home
config_test() {
    LOGSTASH_HOME=$1
    rm -rf /tmp/configtest
    $LOGSTASH_HOME/bin/logstash -f $LOGSTASH_HOME/conf -t -l /tmp/configtest
    cat /tmp/configtest/*
    if grep "The given configuration is invalid"  </tmp/configtest/logstash-plain.log >/dev/null
    then
        log info "logstash configuration error, verify files in $LOGSTASH_HOME/conf"
        rm /tmp/configtest
        return 1
    fi
    return 0
}

# Check configuration file
# params:
#   1- file to check
config_file_test() {
    cfile=$1
    rm -rf /tmp/configtest
    $LOGSTASH_HOME/bin/logstash -f $cfile -t -l /tmp/configtest
    cat /tmp/configtest/*
    if grep "The given configuration is invalid"  </tmp/configtest/logstash-plain.log >/dev/null
    then
        log info "logstash configuration error, verify file $cfile"
        return 1
    fi
    return 0
}

# Send SIGHUP to logstash if not 'auto-reload'
send_sighup_ifneeded() {
    if [[ "`grep "^ExecStart.*--config.reload.automatic" /etc/systemd/system/logstash.service ; echo $?`" == "1" ]]
    then
        log info "No auto-reload, send SIGHUP to logstash.service"
        sudo systemctl --signal=SIGHUP kill logstash.service
    fi
}