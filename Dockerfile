FROM ubuntu:18.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    jq \
    git \
    iputils-ping \
    libcurl4 \
    libicu60 \
    libunwind8 \
    netcat \
    libssl1.0 \
    gnupg \
    lsb-release \
    wget \
    locales \
    apt-transport-https

ENV TZ=Asia/Taipei
ENV LANG="zh_TW.UTF-8"
ENV LC_NUMERIC="zh_TW.UTF-8"
ENV LC_TIME="zh_TW.UTF-8"
ENV LC_COLLATE="zh_TW.UTF-8"
ENV LC_MONETARY="zh_TW.UTF-8"
ENV LC_MESSAGES="zh_TW.UTF-8"
ENV LC_PAPER="zh_TW.UTF-8"
ENV LC_NAME="zh_TW.UTF-8"
ENV LC_ADDRESS="zh_TW.UTF-8"
ENV LC_TELEPHONE="zh_TW.UTF-8"
ENV LC_MEASUREMENT="zh_TW.UTF-8"
ENV LC_IDENTIFICATION="zh_TW.UTF-8"

RUN locale-gen zh_TW.UTF-8

# Java / Apache Maven
RUN apt-get install openjdk-8-jdk
# https://maven.apache.org/download.cgi
RUN apt install maven

# .net-core
# https://docs.microsoft.com/zh-tw/dotnet/core/install/linux-ubuntu#1804-
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb

RUN apt-get update
RUN apt-get install -y dotnet-sdk-6.0

# copy from https://github.com/cenk1cenk2/docker-node-fnm/blob/master/Dockerfile

ENV FNM_VERSION=1.31.0
ENV FNM_DIR=/opt/fnm
ENV FNM_INTERACTIVE_CLI=false
ENV S6_VERSION=2.2.0.3
ENV NODE_JS_VERSION=12.14.1

WORKDIR /tmp

COPY ./rootfs /

# Install s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
  # create directories
  mkdir -p /etc/services.d && mkdir -p /etc/cont-init.d && mkdir -p /s6-bin

SHELL ["/bin/bash", "-c"]

# Install fnm and initiate it
RUN \
  apt-get update && \
  apt-get install -y curl unzip gnupg2 && \
  # install fnm
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "/opt/fnm" --skip-shell && \
  ln -s /opt/fnm/fnm /usr/bin/ && chmod +x /usr/bin/fnm

RUN \
  # smoke test for fnm
  /bin/bash -c "fnm -V"

RUN \
  # install latest node version as default
  /bin/bash -c "source /etc/bash.bashrc && fnm install 10.13" && \
  /bin/bash -c "source /etc/bash.bashrc && fnm install 12.11.1" && \
  /bin/bash -c "source /etc/bash.bashrc && fnm install ${NODE_JS_VERSION}" && \
  /bin/bash -c "source /etc/bash.bashrc && fnm alias default ${NODE_JS_VERSION}"

RUN \
  # add fnm for bash
  /bin/bash -c "source /etc/bash.bashrc && fnm use default" && \
  /bin/bash -c 'source /etc/bash.bashrc && /bin/ln -s "/opt/fnm/aliases/default/bin/node" /usr/bin/node' && \
  /bin/bash -c 'source /etc/bash.bashrc && /bin/ln -s "/opt/fnm/aliases/default/bin/npm" /usr/bin/npm' && \
  /bin/bash -c 'source /etc/bash.bashrc && /bin/ln -s "/opt/fnm/aliases/default/bin/npx" /usr/bin/npx'

RUN \
  # install grail
  curl -s https://downloads.gradle-dn.com/distributions/gradle-7.5.1-bin.zip | unzip -d /opt/gradle gradle-7.5.1-bin.zip
ENV PATH=$PATH:/opt/gradle/gradle-7.5.1/bin

RUN \
  # install golang sdk
  curl -s https://storage.googleapis.com/golang/go1.19.1.linux-amd64.tar.gz | tar -v -C /usr/local -xz  
ENV PATH $PATH:/usr/local/go/bin

COPY ./rootfs/etc/bash.bashrc /root/.bashrc

RUN \
  # smoke test
  /bin/bash -c "source /etc/bash.bashrc && node -v" && \
  /bin/bash -c "source /etc/bash.bashrc && npm -v"

# Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install docker-ce docker-ce-cli containerd.io

RUN rm -rf /var/lib/apt/lists/*


# Azure DevOps Agent

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH=amd64
ARG AGENT_VERSION=2.210.1

WORKDIR /azp
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz; \
    else \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-${TARGETARCH}-${AGENT_VERSION}.tar.gz; \
    fi; \
    curl -LsS "$AZP_AGENTPACKAGE_URL" | tar -xz

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]
