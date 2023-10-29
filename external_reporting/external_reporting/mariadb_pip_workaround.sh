#!/bin/bash

cwd=$(pwd)

apt-get -y install unzip cmake
mkdir -p /tmp/mariadb
cd /tmp/mariadb

wget https://archive.mariadb.org//connector-c-3.3.1/mariadb-connector-c-3.3.1-src.zip
unzip mariadb-connector-c-3.3.1-src.zip
cd mariadb-connector-c-3.3.1-src/
mkdir build
cd build/
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
make
make install

cd ${cwd}