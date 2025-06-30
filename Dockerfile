FROM ubuntu:24.04

LABEL org.opencontainers.image.authors="FS25 Ubuntu Server"
LABEL org.opencontainers.image.description="Farming Simulator 25 Dedicated Server on Ubuntu with Wine"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV WINEDEBUG=-all
ENV DISPLAY=:1
ENV WINE_PREFIX=/home/fs25server/.wine
ENV HOME=/home/fs25server

# Install required packages with retry logic for DNS issues
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    echo "Acquire::Retries \"3\";" > /etc/apt/apt.conf.d/80-retries && \
    apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    software-properties-common \
    xvfb \
    x11vnc \
    fluxbox \
    supervisor \
    novnc \
    websockify \
    python3 \
    python3-numpy \
    curl \
    ca-certificates \
    locales \
    tzdata \
    net-tools \
    xterm \
    mc \
    && rm -rf /var/lib/apt/lists/*

# Add Wine repository and install Wine
RUN dpkg --add-architecture i386 && \
    wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \
    add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ noble main' && \
    apt-get update && \
    apt-get install -y --install-recommends winehq-stable && \
    rm -rf /var/lib/apt/lists/*

# Configure locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create fs25server user
RUN useradd -m -s /bin/bash fs25server

# Copy configuration files
COPY build/rootfs /

# Add installation and startup scripts
ADD build/scripts/install.sh /root/install.sh
ADD build/scripts/startup.sh /startup.sh
ADD build/scripts/run_server.sh /home/fs25server/run_server.sh

# Make scripts executable
RUN chmod +x /root/install.sh /startup.sh /home/fs25server/run_server.sh

# Create necessary directories
RUN mkdir -p /home/fs25server/.wine \
    /opt/fs25/config \
    /opt/fs25/game \
    /opt/fs25/dlc \
    /opt/fs25/installer \
    /home/fs25server/.vnc \
    /var/log/supervisor

# Set permissions
RUN chown -R fs25server:fs25server /home/fs25server /opt/fs25

# Run installation script
RUN /bin/bash /root/install.sh

# Expose ports
EXPOSE 5900/tcp
EXPOSE 6080/tcp
EXPOSE 8080/tcp
EXPOSE 10823/tcp
EXPOSE 10823/udp

# Set working directory
WORKDIR /home/fs25server

# Start supervisor as root (it will handle user switching)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]