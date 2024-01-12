#!/bin/bash
# This script is used to monitor the status of a VM
# If the vm has been on for longer than the specified time, it will be shut down

DATA_DIR=/opt/pve-parent/
RUNTIME_FILE=${DATA_DIR}/runtime
MAX_TIME=72000 # 20 hours
VM_ID=100
DAEMON=0
SLEEP_TIME=60

reset_runtime() {
    echo "Resetting runtime for VM ${VM_ID}"
    echo "0" >${RUNTIME_FILE}
    exit 0
}

send_email() {
    mail -s "$1" ${EMAIL}
}

# Check if the vm should be shut down
check_vm() {
    local runtime=0
    local uptime=0

    # Get the vm uptime in seconds
    uptime=$(qm status ${VM_ID} -verbose | grep uptime | tail -1 | cut -f2 -d" ")
    echo "VM ${VM_ID} has been running for ${uptime} seconds"

    # only update anything if the uptime is greater than 0
    if [ ${uptime} -gt 0 ]; then
        # Figure out how long the vm has been running
        runtime=$(cat ${RUNTIME_FILE})
        runtime=$((runtime + SLEEP_TIME))
        echo "VM ${VM_ID} has been running for a total ${runtime} seconds since last reset"

        # Send an email every hour of runtime
        if [ $((runtime % 7200)) -eq 0 ]; then
            # convert seconds to hours
            local hours=$(echo "scale=2; $runtime / 3600" | bc)
            send_email "VM ${VM_ID} has been running for ${runtime} Hours"
        fi
        # If the vm has been on for longer than the specified time, it will be shut down
        if [ ${runtime} -gt ${MAX_TIME} ]; then
            echo "Shutting down VM ${VM_ID}"
            send_email "VM ${VM_ID} is being shut down"
            qm shutdown ${VM_ID}
        else
            echo ${runtime} >${RUNTIME_FILE}
        fi
    fi
}

OPTIONS=m:t:dre:
LONGOPTS=vmid:,max_time:,daemon,reset,email:

PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS -- "$@") || exit
eval set -- "$PARSED"

while true; do
    case "$1" in
    -m | --vmid)
        VM_ID="$2"
        shift 2
        ;;
    -t | --max_time)
        MAX_TIME="$2"
        shift 2
        ;;
    -d | --daemon)
        DAEMON=1
        shift
        ;;
    -r | --reset)
        reset_runtime
        shift
        ;;
    -e | --email)
        EMAIL="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    esac
done

# If the runtime file does not exist, create it
if [ ! -f ${RUNTIME_FILE} ]; then
    mkdir -p ${DATA_DIR}
    echo "0" >${RUNTIME_FILE}
fi

if [ ${DAEMON} -eq 1 ]; then
    echo "Running in daemon mode"
    while true; do
        check_vm &
        sleep ${SLEEP_TIME}
    done
else
    check_vm
fi
