FROM lscr.io/linuxserver/code-server:4.92.2-ls231

RUN apt update && apt install -y \
    openssh-client telnet iputils-ping \
    build-essential

# Install docker client only, reference: https://docs.docker.com/engine/install/ubuntu/
RUN  apt-get update && \
  apt-get install -y ca-certificates curl && \
  install -m 0755 -d /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
  chmod a+r /etc/apt/keyrings/docker.asc && \
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
     tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get update && \
  apt install -y docker-ce-cli

RUN groupadd docker
# RUN useradd -m abc
RUN usermod -aG docker abc
