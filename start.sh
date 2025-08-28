#!/bin/bash
# Start QEMU with VNC
qemu-system-x86_64 \
    -hda /vm/win98.qcow2 \
    -m 256 \
    -vnc 0.0.0.0:$((VNC_PORT-5900)) \
    -boot c \
    -net nic \
    -net user &

# Start noVNC to webify VNC
websockify --web=/usr/share/novnc/ $NOVNC_PORT localhost:$VNC_PORT
