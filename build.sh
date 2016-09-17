#!/bin/bash

set -euxo pipefail

yum -y install epel-release
curl -o /etc/yum.repos.d/decathorpe-syncthing-epel-7.repo https://copr.fedorainfracloud.org/coprs/decathorpe/syncthing/repo/epel-7/decathorpe-syncthing-epel-7.repo
yum -y install syncthing

mkdir -p /home/syncthing/.config/syncthing

yum clean all
