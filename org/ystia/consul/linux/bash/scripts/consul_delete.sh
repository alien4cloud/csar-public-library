#!/usr/bin/env bash

source ${utils_scripts}/utils.sh

set +e

log begin

ensure_home_var_is_set

INSTALL_DIR=$(eval readlink -f "${INSTALL_DIR}")


log info "Remove consul systemd service"
#sudo systemctl disable
sudo rm -f /etc/systemd/system/consul.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

log info "Remove all consul related files"
rm -rf ${INSTALL_DIR}

log info "Remove all flags to avoid error when reinstalling it on a node"
rm -rf ${YSTIA_DIR}/consul_env.sh
rm -rf ${YSTIA_DIR}/.${NODE}*

# DNSMASQ
if [[ "${INSTALL_DNSMASQ}" == "true" ]]; then
    OS_DISTRIB=$(get_os_distribution)
    log info "Restore the previous configuration"
    case "${OS_DISTRIB}" in
        "ubuntu" | "debian" | "mint")
            [[ -e /etc/network/interfaces.d/eth0.cfg.ystiasave ]] && sudo mv /etc/network/interfaces.d/eth0.cfg.ystiasave /etc/network/interfaces.d/eth0.cfg
            sudo ifdown eth0; sudo ifup eth0
            ;;
        "centos" | "redhat" | "fedora")
            [[ -e /etc/resolv.conf.ystiasave ]] && sudo mv /etc/resolv.conf.ystiasave /etc/resolv.conf
            for fName in $(ls /etc/sysconfig/network-scripts/ifcfg-eth*)
            do
                fNameSave=$(dirname ${fName})/z.$(basename ${fName}).ystiasave
                [[ -e ${fNameSave} ]] && sudo mv ${fNameSave} ${fName}
            done
            ;;
    esac

    if [[ "${DNSMASQ_PREVIOUS}" == "true" ]]; then
        log info "Restore the previous dnsmasq configuration"
        [[ -e /etc/dnsmasq.conf.ystiasave ]] && sudo mv /etc/dnsmasq.conf.ystiasave /etc/dnsmasq.conf
        [[ -e /etc/default/dnsmasq.ystiasave ]] && sudo mv /etc/default/dnsmasq.ystiasave /etc/default/dnsmasq.conf
        sudo service dnsmasq restart
    else
        log info "Uninstall dnsmasq"
        case "${OS_DISTRIB}" in
            "ubuntu" | "debian" | "mint")
                sudo apt-get remove dnsmasq
                ;;
            "centos" | "redhat" | "fedora")
                sudo yum remove -y dnsmasq
                ;;
        esac
    fi

fi

log end
