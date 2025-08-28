# Base image
FROM ubuntu:22.04

# Set environment variables for ports (customizable)
ENV VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    VPS_MEMORY=4096 \
    VPS_CORES=2 \
    VPS_NAME=ubuntu22-vps \
    ISO_URL=https://releases.ubuntu.com/jammy/ubuntu-22.04.5-desktop-amd64.iso \
    QCOW2_IMAGE=/vm/ubuntu22.qcow2

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        qemu-system-x86 \
        qemu-utils \
        wget \
        novnc \
        websockify \
        python3 \
        x11vnc \
        xvfb \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /vm

WORKDIR /vm

# Download Ubuntu 22.04 Desktop ISO
RUN wget -O ubuntu22.iso "$ISO_URL"

# Create an empty qcow2 disk (30GB)
RUN qemu-img create -f qcow2 $QCOW2_IMAGE 30G

# Expose ports
EXPOSE $VNC_PORT
EXPOSE $NOVNC_PORT

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
