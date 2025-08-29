# Base image
FROM ubuntu:22.04

# Environment variables
ENV VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    VPS_MEMORY=2048 \
    VPS_CORES=2 \
    VPS_NAME=tiny10-vps \
    ISO_URL=https://archive.org/download/tiny-10-b-2/Tiny10%20B2.iso \
    QCOW2_IMAGE=/vm/tiny10.qcow2

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

# Download Tiny10 B2 ISO
RUN wget -O tiny10.iso "$ISO_URL"

# Create an empty qcow2 disk (15GB for Tiny10)
RUN qemu-img create -f qcow2 $QCOW2_IMAGE 15G

# Expose ports
EXPOSE $VNC_PORT
EXPOSE $NOVNC_PORT

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
