ARG OS_VERSION=ubuntu18.04
ARG VERSION=1.0.0
FROM pickonefish/azure-devops-agent:${OS_VERSION}-${VERSION}

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

COPY fnm/install ./fnm/install
RUN chmod +x ./fnm/install

# Install fnm and initiate it
RUN \
  apt-get update && \
  apt-get install -y curl unzip gnupg2 && \
  # install fnm
  # curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "/opt/fnm" --skip-shell && \
  fnm/install --install-dir "/opt/fnm" --skip-shell && \
  ln -s /opt/fnm/fnm /usr/bin/ && chmod +x /usr/bin/fnm

RUN \
  # smoke test for fnm
  /bin/bash -c "fnm -V"

RUN \
  # install latest node version as default
  /bin/bash -c "source /etc/bash.bashrc && fnm install ${NODE_JS_VERSION}" && \
  /bin/bash -c "source /etc/bash.bashrc && fnm alias default ${NODE_JS_VERSION}"

RUN \
  # add fnm for bash
  /bin/bash -c "source /etc/bash.bashrc && fnm use default" && \
  /bin/bash -c 'source /etc/bash.bashrc && /bin/ln -s "/opt/fnm/aliases/default/bin/node" /usr/bin/node' && \
  /bin/bash -c 'source /etc/bash.bashrc && /bin/ln -s "/opt/fnm/aliases/default/bin/npm" /usr/bin/npm' && \
  /bin/bash -c 'source /etc/bash.bashrc && /bin/ln -s "/opt/fnm/aliases/default/bin/npx" /usr/bin/npx'

COPY ./rootfs/etc/bash.bashrc /root/.bashrc

RUN \
  # smoke test
  /bin/bash -c "source /etc/bash.bashrc && node -v" && \
  /bin/bash -c "source /etc/bash.bashrc && npm -v"

ENTRYPOINT [ "./start.sh" ]
