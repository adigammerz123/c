FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    wget \
    curl \
    nano \
    git \
    neofetch \
    ca-certificates \
    apt-transport-https \
    software-properties-common

# Install Docker
RUN retry_curl() { \
    curl -sSf "$1" || (sleep 5 && curl -sSf "$1") || (sleep 10 && curl -sSf "$1"); \
}; \
retry_curl https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# Install sshx.io
RUN curl -sSf https://sshx.io/get | sh

# Configure systemd (for DinD)
RUN apt-get install -y systemd
RUN systemctl set-default multi-user.target

# Configure Docker daemon to listen on TCP (for DinD access)
RUN echo '{ "hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"] }' > /etc/docker/daemon.json

# Expose Docker port and SSHX port
EXPOSE 2375
EXPOSE 22

# Start systemd and SSHX
CMD ["/lib/systemd/systemd"]
