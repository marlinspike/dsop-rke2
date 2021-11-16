#!/bin/bash
set -e

export INSTALL_RKE2_TYPE="${type}"
export INSTALL_RKE2_VERSION="${rke2_version}"

if [ "$${DEBUG}" == 1 ]; then
  set -x
fi

# info logs the given argument at info log level.
info() {
    echo "[INFO] " "$@"
}

# warn logs the given argument at warn log level.
warn() {
    echo "[WARN] " "$@" >&2
}

# fatal logs the given argument at fatal log level.
fatal() {
    echo "[ERROR] " "$@" >&2
    exit 1
}

read_os() {
  ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
  VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')
}

get_installer() {
  curl -fsSL https://get.rke2.io -o install.sh
  chmod u+x install.sh
}

do_download() {
  read_os
  get_installer

  case $ID in
  centos)
    yum install -y unzip

    # TODO: Determine minimum supported version, for now just carry on assuming ignorance
    case $VERSION in
    7*)
      info "Identified CentOS 7"
      INSTALL_RKE2_METHOD='yum' INSTALL_RKE2_TYPE="${type}" ./install.sh

      ;;
    8*)
      info "Identified CentOS 8"
      INSTALL_RKE2_METHOD='yum' INSTALL_RKE2_TYPE="${type}" ./install.sh

      ;;
    esac
    ;;

  rhel)
    yum install -y unzip

    case $VERSION in
    7*)
      info "Identified RHEL 7"

      yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
      INSTALL_RKE2_METHOD='yum' INSTALL_RKE2_TYPE="${type}" ./install.sh
      ;;
    8*)
      info "Identified RHEL 8"

      INSTALL_RKE2_METHOD='yum' INSTALL_RKE2_TYPE="${type}" ./install.sh
      ;;
    esac

    ;;

  ubuntu)
    info "Identified Ubuntu"
    # TODO: Determine minimum supported version, for now just carry on assuming ignorance
    apt update -y

    apt install -y less iptables resolvconf linux-headers-$(uname -r) telnet jq

    INSTALL_RKE2_METHOD='tar' INSTALL_RKE2_TYPE="${type}" ./install.sh

    # sysctl -w vm.max_map_count=262144

    ;;
  amzn)
    # azurecli already present, only need rke2
    yum update -y

    case $VERSION in
    2)
      info "Identified Amazon Linux 2"
      INSTALL_RKE2_METHOD='tar' INSTALL_RKE2_TYPE="${type}" ./install.sh
      ;;
    *)
      info "Identified Amazon Linux 1"
      INSTALL_RKE2_METHOD='tar' INSTALL_RKE2_TYPE="${type}" ./install.sh
      ;;
    esac
    ;;
  *)
    fatal "$${ID} $${VERSION} is not currently supported"
    ;;
  esac
}

{
  do_download
}
