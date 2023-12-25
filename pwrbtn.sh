#!/bin/bash

# Check if vm 100 is running
if qm status 100 | grep -q running; then
    # If yes, shutdown vm 100
    qm shutdown 100
else
    # If no, start vm 100
    qm start 100
fi