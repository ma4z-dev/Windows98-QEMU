#!/bin/bash

# Print environment variables for debugging
echo "==============================="
echo "VPS_MEMORY  = ${VPS_MEMORY} MB"
echo "VPS_CORES   = ${VPS_CORES}"
echo "VNC_PORT    = ${VNC_PORT} (host mapped)"
echo "NOVNC_PORT  = ${NOVNC_PORT}"
echo "VM Disk     = /vm/win98.qcow2"
echo "==============================="

# Ensure the VM disk exists
if [ ! -f /vm/win98.qcow2 ]; then
  echo "ERROR: VM disk not found!"
  exit 1
fi

# Use a fixed QEMU display number
DISPLAY_NUM=0
QEMU_VNC_PORT=$((5900 + DISPLAY_NUM))

echo "Starting QEMU with display :${DISPLAY_NUM} (TCP ${QEMU_VNC_PORT})"
qemu-system-x86_64 \
    -hda /vm/win98.qcow2 \
    -m ${VPS_MEMORY} \
    -smp ${VPS_CORES} \
    -vnc :${DISPLAY_NUM} \
    -boot c \
    -net nic \
    -net user &

QEMU_PID=$!
sleep 5

# Check if QEMU started
if ps -p $QEMU_PID > /dev/null; then
    echo "QEMU started successfully (PID $QEMU_PID)."
else
    echo "QEMU failed to start!"
    exit 1
fi

# Start noVNC mapped to the host port
echo "Starting noVNC on port ${NOVNC_PORT} → QEMU TCP ${QEMU_VNC_PORT}"
websockify --web=/usr/share/novnc/ $NOVNC_PORT localhost:$QEMU_VNC_PORT
