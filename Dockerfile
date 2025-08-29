# Base image
FROM ubuntu:22.04

# Environment variables
ENV VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    VPS_MEMORY=2048 \
    VPS_CORES=2 \
    VPS_NAME=win81-vps \
    ISO_URL=https://archive.org/download/win-8.1-english-x-64-x-86/Win8.1_English_x32.iso \
    QCOW2_IMAGE=/vm/win81.qcow2

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

# Download Windows 8.1 ISO
RUN wget -O win81.iso "$ISO_URL"

# Create an empty qcow2 disk (30GB for Win8.1)
RUN qemu-img create -f qcow2 $QCOW2_IMAGE 30G

# Expose ports
EXPOSE $VNC_PORT
EXPOSE $NOVNC_PORT

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
