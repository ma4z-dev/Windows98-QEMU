#!/bin/bash
# Start QEMU with VNC
qemu-system-x86_64 \
    -hda /vm/win98.qcow2 \
    -m ${VPS_MEMORY} \
    -smp ${VPS_CORES} \
    -vnc 0.0.0.0:${VNC_PORT} \
    -boot c \
    -net nic \
    -net user &

# Start noVNC to webify VNC
websockify --web=/usr/share/novnc/ $NOVNC_PORT localhost:$VNC_PORT
