# Base image
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Enable 32-bit architecture for Wine
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    zsh \
    nsis \
    wine-stable \
    wine32 \
    libwine:i386 \
    libwine-dev:i386 \
    winbind && \
    rm -rf /var/lib/apt/lists/*

# Download and install NSIS
RUN wget https://sourceforge.net/projects/nsis/files/NSIS%203/3.10/nsis-3.10-setup.exe -O /tmp/nsis-3.10-setup.exe && \
   wine /tmp/nsis-3.10-setup.exe /S && \
   rm /tmp/nsis-3.10-setup.exe

# Disable graphical display for Wine
ENV DISPLAY=""

# Set Wine configuration
ENV WINEPREFIX /root/.wine

# Set working directory
WORKDIR /workspace

# Add NSIS to the path
ENV PATH "$PATH:/root/.wine/drive_c/Program Files/NSIS"
