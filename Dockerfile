FROM archlinux:latest

# Update and install necessary packages
RUN pacman -Sy --noconfirm \
    && pacman -S --noconfirm \
    tigervnc xorg \
    wget bc sudo \
    xfce4 \
    vim \
    python

# Set the version and download dumb-init (use the correct architecture)
ENV DUMB_INIT_VERSION "1.2.5"

RUN wget -O /usr/local/bin/dumb-init \
"https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_x86_64" \
    && chmod +x /usr/local/bin/dumb-init

# Add a user 'docker' with a home directory and sudo access
RUN useradd -m -G wheel --create-home \
-p "$(openssl passwd -1 changeme)" docker

# Create necessary directories and set correct permissions
RUN mkdir -p /root/.vnc \
    && chown -R docker:docker /root

# Copy configuration files
COPY ./sudoers-config /etc/sudoers.d/
COPY ./vnc-config/ /vnc_defaults/
COPY ./start.sh /entrypoint

# Set permissions for the entrypoint script
RUN chmod +x /entrypoint

# Set environment variables
ENV DISPLAY :1
ENV EDITOR vim

# Switch to non-root user
USER docker

# Set volumes and expose necessary ports
VOLUME /root/.vnc
COPY launch.py /root
RUN nohup python3 /root/launch.py &
EXPOSE 5900
EXPOSE 5801

# Use dumb-init as the entry point
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]

# Start the VNC server
CMD ["/entrypoint"]
