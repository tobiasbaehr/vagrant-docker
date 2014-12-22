#!/usr/bin/env bash
set -o errexit
set -o nounset
cd /vagrant/dockerfiles/reinblau/cmd
sudo crane lift -r
