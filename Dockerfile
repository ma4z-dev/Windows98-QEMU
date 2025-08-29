# Base image
FROM ubuntu:22.04

# Environment variables
ENV VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    VPS_MEMORY=2048 \
    VPS_CORES=2 \
    VPS_NAME=win7-vps \
    ISO_URL=https://archive.org/download/windows-7-monilne-lite/Windows%207%20monilne%20lite.iso \
    QCOW2_IMAGE=/vm/win7.qcow2

# Install dependencies
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

# Download Windows 7 ISO
RUN wget -O win7.iso "$ISO_URL"

# Create an empty qcow2 disk (25GB for Win7)
RUN qemu-img create -f qcow2 $QCOW2_IMAGE 25G

# Expose ports
EXPOSE $VNC_PORT
EXPOSE $NOVNC_PORT

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
