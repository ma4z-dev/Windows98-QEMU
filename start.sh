#!/bin/bash

# Print environment variables for debugging
echo "==============================="
echo "VPS_MEMORY  = ${VPS_MEMORY} MB"
echo "VPS_CORES   = ${VPS_CORES}"
echo "VNC_PORT    = ${VNC_PORT} (host mapped)"
echo "NOVNC_PORT  = ${NOVNC_PORT}"
echo "VM Disk     = /vm/win2000.qcow2"
echo "ISO File    = /vm/win2000.iso"
echo "==============================="

# Ensure the VM disk exists (create if missing)
if [ ! -f /vm/win2000.qcow2 ]; then
  echo "VM disk not found, creating new 8G disk..."
  qemu-img create -f qcow2 /vm/win2000.qcow2 8G
fi

# Use a fixed QEMU display number
DISPLAY_NUM=0
QEMU_VNC_PORT=$((5900 + DISPLAY_NUM))

# If ISO exists, boot installer. Otherwise, boot from disk.
if [ -f /vm/win2000.iso ]; then
  echo "Booting from Windows 2000 ISO installer..."
  BOOT_ARGS="-cdrom /vm/win2000.iso -boot d"
else
  echo "Booting directly from disk..."
  BOOT_ARGS="-boot c"
fi

echo "Starting QEMU with display :${DISPLAY_NUM} (TCP ${QEMU_VNC_PORT})"
qemu-system-x86_64 \
    -drive file=/vm/win2000.qcow2,format=qcow2,if=ide \
    -m ${VPS_MEMORY} \
    -smp ${VPS_CORES} \
    -vnc :${DISPLAY_NUM} \
    -cpu pentium3 \
    -machine pc \
    -net nic -net user \
    -device qemu-xhci \
    -device usb-tablet \
    ${BOOT_ARGS} &

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
