#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

set -x
set -v # verbose
set -u # no unbound variables

apt-get -qq update
apt-get -qq install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y

apt-get -qq update
apt-get -qq upgrade -y

# install docker and utils

until docker --version; do
  apt-get -qq install docker-ce -y
  sleep 1
done

until jq --version; do
  apt-get -qq install jq -y
  sleep 1
done

until aws --version; do
  apt-get -qq install awscli -y
  sleep 1
done

# start docker and fix permissions
service docker start
usermod -a -G docker ubuntu

# auto-start docker
systemctl enable --now docker

# install docker-compose
until docker-compose version; do
  curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  sleep 10
done

WD=$(pwd)

{
  # configure crontab to run on startup
  echo "@reboot (cd ${WD} && ${WD}/bootstrap.sh 2>&1) | logger -t catalyst-owner-bootstrap"

  # and to update every 5 minutes
  echo "*/5 * * * * (cd ${WD} && ${WD}/crontab.sh 2>&1) | logger -t catalyst-owner-cron"
} > .crontab

chown ubuntu:ubuntu "${WD}/.crontab"
crontab -u ubuntu "${WD}/.crontab"

# reboot to verify everyting is OK
sudo reboot
