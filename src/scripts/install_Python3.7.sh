#!/usr/bin/env bash
sudo apt-get install -y build-essential checkinstall libreadline-gplv2-dev \
    libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev \
    libbz2-dev zlib1g-dev openssl libffi-dev python3-dev python3-setuptools wget
PYTHON=3.7.1
cd ~/src
wget https://www.python.org/ftp/python/${PYTHON}/Python-${PYTHON}.tar.xz
tar xvf Python-${PYTHON}.tar.xz
cd Python-${PYTHON}
./configure
sudo make altinstall
