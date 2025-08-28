# Base image
FROM ubuntu:22.04

# Set environment variables for ports (customizable)
ENV VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    IMAGE_URL=https://github.com/zenllc/VerseVM/releases/download/assets/win98-desktop.qcow2.gz

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        qemu-system-x86 \
        wget \
        gzip \
        novnc \
        websockify \
        python3 \
        x11vnc \
        xvfb && \
    rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /vm /noVNC

WORKDIR /vm

# Download and decompress Windows 98 image
RUN wget -O win98.qcow2.gz $IMAGE_URL && \
    gzip -d win98.qcow2.gz

# Copy noVNC to container
RUN ln -s /usr/share/novnc /noVNC

# Expose ports
EXPOSE $VNC_PORT
EXPOSE $NOVNC_PORT

# Start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
