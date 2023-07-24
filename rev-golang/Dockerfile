ARG OS_VERSION=ubuntu18.04
ARG VERSION=1.0.0
FROM pickonefish/azure-devops-agent:${OS_VERSION}-docker-${VERSION}

RUN \
  # install golang sdk
  curl -s https://storage.googleapis.com/golang/go1.19.1.linux-amd64.tar.gz | tar -v -C /usr/local -xz  
ENV PATH $PATH:/usr/local/go/bin

ENTRYPOINT [ "./start.sh" ]
