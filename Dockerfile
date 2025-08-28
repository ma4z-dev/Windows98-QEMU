# Base image
FROM ubuntu:22.04

# Set environment variables for ports (customizable)
ENV VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    VPS_MEMORY=2048 \
    VPS_CORES=2 \
    VPS_NAME=winvista-vps \
    ISO_URL=https://archive.org/download/windows-vista-sp0-sp1-sp2-msdn-iso-files-en-de-ru-tr-x86-x64/tr_windows_vista_x64_dvd_x12-61213.iso \
    QCOW2_IMAGE=/vm/winvista.qcow2

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

# Download Windows Vista ISO
RUN wget -O winvista.iso "$ISO_URL"

# Create an empty qcow2 disk (25GB for Vista)
RUN qemu-img create -f qcow2 $QCOW2_IMAGE 25G

# Expose ports
EXPOSE $VNC_PORT
EXPOSE $NOVNC_PORT

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
