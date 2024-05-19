FROM ubuntu:20.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

COPY ./rootfs/etc/apt/sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    jq \
    git \
    iputils-ping \
    libcurl4 \
#    libicu60 \
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


# Azure DevOps Agent

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH=x64
ARG AGENT_VERSION=3.239.1

WORKDIR /azp
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-${TARGETARCH}-${AGENT_VERSION}.tar.gz; \
    else \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-${TARGETARCH}-${AGENT_VERSION}.tar.gz; \
    fi; \
    curl -LsS "$AZP_AGENTPACKAGE_URL" | tar -xz

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]
