# Base image
FROM ubuntu:22.04

# Environment variables
ENV VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    VPS_MEMORY=1024 \
    VPS_CORES=1 \
    VPS_NAME=winxp-vps \
    ISO_URL=https://archive.org/download/windows-xp-all-sp-msdn-iso-files-en-de-ru-tr-x86-x64/en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso \
    QCOW2_IMAGE=/vm/winxp.qcow2

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

# Download Windows XP ISO
RUN wget -O winxp.iso "$ISO_URL"

# Create an empty qcow2 disk (15GB for XP)
RUN qemu-img create -f qcow2 $QCOW2_IMAGE 15G

# Expose ports
EXPOSE $VNC_PORT
EXPOSE $NOVNC_PORT

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
