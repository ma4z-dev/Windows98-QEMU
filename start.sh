#!/bin/bash

echo "==============================="
echo "VPS_MEMORY  = ${VPS_MEMORY} MB"
echo "VPS_CORES   = ${VPS_CORES}"
echo "VNC_PORT    = ${VNC_PORT} (host mapped)"
echo "NOVNC_PORT  = ${NOVNC_PORT}"
echo "VM Disk     = /vm/win81.qcow2"
echo "ISO File    = /vm/win81.iso"
echo "==============================="

# Ensure VM disk exists
if [ ! -f /vm/win81.qcow2 ]; then
  echo "VM disk not found, creating new 30G disk..."
  qemu-img create -f qcow2 /vm/win81.qcow2 30G
fi

# Fixed display number
DISPLAY_NUM=0
QEMU_VNC_PORT=$((5900 + DISPLAY_NUM))

# Boot arguments
if [ -f /vm/win81.iso ]; then
  echo "Booting from Windows 8.1 ISO installer..."
  BOOT_ARGS="-cdrom /vm/win81.iso -boot d"
else
  echo "Booting directly from disk..."
  BOOT_ARGS="-boot c"
fi

echo "Starting QEMU with display :${DISPLAY_NUM} (TCP ${QEMU_VNC_PORT})"
qemu-system-x86_64 \
    -drive file=/vm/win81.qcow2,format=qcow2,if=ide \
    -m ${VPS_MEMORY} \
    -smp ${VPS_CORES} \
    -vnc :${DISPLAY_NUM} \
    -cpu pentium3 \
    -machine pc \
    -net nic -net user \
    -vga std \
    ${BOOT_ARGS} &

QEMU_PID=$!
sleep 5

# Verify QEMU started
if ps -p $QEMU_PID > /dev/null; then
    echo "QEMU started successfully (PID $QEMU_PID)."
else
    echo "QEMU failed to start!"
    exit 1
fi

# Start noVNC
echo "Starting noVNC on port ${NOVNC_PORT} → QEMU TCP ${QEMU_VNC_PORT}"
websockify --web=/usr/share/novnc/ $NOVNC_PORT localhost:$QEMU_VNC_PORT
