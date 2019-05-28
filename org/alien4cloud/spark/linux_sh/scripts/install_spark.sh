#!/bin/bash -e

# Ensure that the last executed operation has been successfully executed, exit with error if not.
#
# args:
# $1 operation description (just for logs).
ensure_success() {
  if [ "$?" -ne 0 ]; then
    echo "The following operation failed ! Aborting : $1" >&2;
    exit 1;
  else
    echo "The following operation succeed: $1";
  fi
}

# Download the file using the available download command: wget or curl.
#
# args:
# $1 download description.
# $2 download link.
# $3 output file.
download() {
  echo "Will download $1 from $2 into $3"

  if [ -f /usr/bin/wget ]; then
    DOWNLOADER="wget"
  elif [ -f /usr/bin/curl ]; then
    DOWNLOADER="curl"
  fi

  if [ "$DOWNLOADER" = "wget" ];then
    Q_FLAG="--no-check-certificate -q"
    O_FLAG="-O"
    LINK_FLAG=""
  elif [ "$DOWNLOADER" = "curl" ];then
    Q_FLAG="-ks"
    O_FLAG="-Lo"
    LINK_FLAG="-O"
  else
    echo "Nor wget or curl is present, can't download anything, aborting !" >&2
    exit 1
  fi
  echo "Downloading using command: $DOWNLOADER $Q_FLAG $O_FLAG $3 $LINK_FLAG $2"
  sudo $DOWNLOADER $Q_FLAG $O_FLAG $3 $LINK_FLAG $2 >/dev/null 2>&1
  ensure_success "Downloading using command: $DOWNLOADER $Q_FLAG $O_FLAG $3 $LINK_FLAG $2"
}

if [ -f "${SPARK_INSTALL_DIR}/spark.tgz" ]; then
  exit 0
fi

sudo mkdir "${SPARK_INSTALL_DIR}"
download "Spark" "${SPARK_DOWNLOAD_URL}" "${SPARK_INSTALL_DIR}/spark.tgz"
sudo tar -xzf "${SPARK_INSTALL_DIR}/spark.tgz" -C "${SPARK_INSTALL_DIR}/"
