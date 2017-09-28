#!/bin/bash -e

echo "Loading ssl utils"

# Generate a key pair and keystore with certificat sign by CA.
#
# Need envs to be set :
# - $ssl: ssl dir (including ca key and certificat) location.
# - $CA_PASSPHRASE
#
# ARGS:
# - $1 cn
# - $2 name
# - $3 KEYSTORE_PWD
# - $4 single IP to be put in subjectAltName
#
# Returns a temp folder containing.
# - ${name}-key.pem
# - ${name}-cert.pem
# - ${name}-keystore.p12
# - ca.pem
# - ca.csr
#
# Should be deleted after usage.
generateKeyAndStore() {
	CN=$1
	NAME=$2
	KEYSTORE_PWD=$3
	IP=$4

	TEMP_DIR=`mktemp -d`

	# echo "Generate client key"
	# Generate a key pair
	openssl genrsa -out ${TEMP_DIR}/${NAME}-key.pem 4096
	openssl req -subj "/CN=${CN}" -sha256 -new \
		-key ${TEMP_DIR}/${NAME}-key.pem \
		-out ${TEMP_DIR}/${NAME}.csr
	# Sign the key with the CA and create a certificate
	echo "[ ssl_client ]" > ${TEMP_DIR}/extfile.cnf
	echo "extendedKeyUsage=serverAuth,clientAuth" >> ${TEMP_DIR}/extfile.cnf
	if [ "${IP}" ]; then
  	sudo echo "subjectAltName = IP:${IP}" >> ${TEMP_DIR}/extfile.cnf
	fi
	openssl x509 -req -days 365 -sha256 \
	        -in ${TEMP_DIR}/${NAME}.csr -CA $ssl/ca.pem -CAkey $ssl/ca-key.pem \
	        -CAcreateserial -out ${TEMP_DIR}/${NAME}-cert.pem \
	        -passin pass:$CA_PASSPHRASE \
	        -extfile ${TEMP_DIR}/extfile.cnf -extensions ssl_client

	# poulate key store
	# echo "Generate client keystore using openssl"
	openssl pkcs12 -export -name ${NAME} \
			-in ${TEMP_DIR}/${NAME}-cert.pem -inkey ${TEMP_DIR}/${NAME}-key.pem \
			-out ${TEMP_DIR}/${NAME}-keystore.p12 -chain \
			-CAfile $ssl/ca.pem -caname root \
			-password pass:$KEYSTORE_PWD

	cp $ssl/ca.pem ${TEMP_DIR}/ca.pem
	openssl x509 -outform der -in $ssl/ca.pem -out ${TEMP_DIR}/ca.csr

	# return the directory
	echo ${TEMP_DIR}
}

# Try to guess the Operating System distribution
# The guessing algorithm is:
#   1- use lsb_release retrieve the distribution name (should normally be present it's listed as requirement of VM images in installation guide)
#   2- If lsb_release is not present check if yum is present. If yes assume that we are running Centos
#   3- Otherwise check if apt-get is present. If yes assume that we are running Ubuntu
#   4- Otherwise give-up and return "unknown"
#
# Any way the returned string is in lower case.
# This function prints the result to the std output so you should use the following form to retrieve it:
# os_dist="$(get_os_distribution)"
get_os_distribution () {
  rname="unknown"
  if  [[ "$(which lsb_release)" != "" ]]
    then
    rname=$(lsb_release -si | tr [:upper:] [:lower:])
  else
    if [[ "$(which yum)" != "" ]]
      then
      # assuming we are on Centos
      rname="centos"
    elif [[ "$(which apt-get)" != "" ]]
      then
      # assuming we are on Ubuntu
      rname="ubuntu"
    fi
  fi
  echo ${rname}
}

# Install a CA certificate into the system ca-certificates file
#
# WARNING: only works for Ubuntu os
# TODO: test and adapt for centos
#
# ARGS:
# - $1 path to the CA to install
install_CAcertificate() {
	distro=$(get_os_distribution)
	CAfile=$1
	echo "Installing CA ${CAfile} into the system..."
	echo "OS is : "$distro
	if [[ $distro == "centos" ]]; then
		sudo cp $CAfile /etc/pki/ca-trust/source/anchors/_ca.crt
		sudo update-ca-trust extract
	elif [[ $distro == "ubuntu" ]]; then
			sudo cp $CAfile /usr/local/share/ca-certificates/_ca.crt
			sudo update-ca-certificates
	else
		echo "OS not yet supported"
	fi


	echo "CA ${CAfile} installed"
}
