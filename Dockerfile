# Base image
FROM ubuntu:22.04

# Environment variables
ENV VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    VPS_MEMORY=2048 \
    VPS_CORES=2 \
    VPS_NAME=tiny11-vps \
    ISO_URL=https://archive.org/download/tiny-11-NTDEV/tiny11%20b1.iso \
    QCOW2_IMAGE=/vm/tiny11.qcow2

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

# Download Tiny11 B1 ISO
RUN wget -O tiny11.iso "$ISO_URL"

# Create an empty qcow2 disk (40GB for Tiny11)
RUN qemu-img create -f qcow2 $QCOW2_IMAGE 40G

# Expose ports
EXPOSE $VNC_PORT
EXPOSE $NOVNC_PORT

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
