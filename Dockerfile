# Base image
FROM ubuntu:22.04

# Set environment variables for ports (customizable)
ENV VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    VPS_MEMORY=1024 \
    VPS_CORES=1 \
    VPS_NAME=win2000-vps \
    ISO_URL=https://archive.org/download/win-2000-pro/W2K2011.ISO \
    QCOW2_IMAGE=/vm/win2000.qcow2

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

# Download Windows 2000 ISO
RUN wget -O win2000.iso "$ISO_URL"

# Create an empty qcow2 disk (8GB is plenty for Win2000)
RUN qemu-img create -f qcow2 $QCOW2_IMAGE 8G

# Expose ports
EXPOSE $VNC_PORT
EXPOSE $NOVNC_PORT

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
