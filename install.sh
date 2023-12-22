#!/bin/bash
# This script installs the monitor script

pushd /opt >/dev/null

# Clone the repo
git clone https://github.com/mdsketch/pve-parent

pushd pve-parent >/dev/null

# Install monitor.service
cp monitor.service /etc/systemd/system/monitor.service
systemctl daemon-reload
systemctl enable --now monitor.service

# Install cronjob
cp monitor.cron /etc/cron.d/monitor

