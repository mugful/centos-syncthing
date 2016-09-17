centos-syncthing
================

A Syncthing image built on top of CentOS 7.

Build
-----

    git clone https://github.com/dockingbay/centos-syncthing
    cd centos-syncthing
    docker build --force-rm -t dockingbay/centos-syncthing:latest .

Run
---


    docker run \
        --name syncthing \
        dockingbay/centos-syncthing:latest
