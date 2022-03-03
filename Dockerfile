FROM ubuntu:18.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
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

# Nodejs / NPM / NVS
WORKDIR /app
RUN git clone https://github.com/jasongin/nvs
RUN chmod 777 nvs/nvs.sh
RUN nvs/nvs.sh install
RUN source ~/.bashrcs

RUN nvs add 12.20
RUN nvs use 12.20 

RUN /usr/bin/node -v
RUN /usr/bin/npm -v

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
ARG AGENT_VERSION=2.200.2

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
