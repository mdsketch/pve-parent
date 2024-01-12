#!/bin/bash

# Check how long since the last button press
if [ $(($(date +%s) - $(cat /opt/pve-parent/pwrbtn-lastpress))) -lt 15 ]; then
    # If less than 10 seconds, exit
    exit 0
fi


date +%s > /opt/pve-parent/pwrbtn-lastpress

# Check if vm 100 is running
if qm status 100 | grep -q running; then
    # If yes, shutdown vm 100
    qm shutdown 100
else
    # If no, start vm 100
    qm start 100
fi