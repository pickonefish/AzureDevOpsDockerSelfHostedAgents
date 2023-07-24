ARG OS_VERSION=ubuntu18.04
ARG VERSION=1.0.0
FROM pickonefish/azure-devops-agent:${OS_VERSION}-docker-${VERSION}

RUN apt-get update

# Java
RUN apt-get install openjdk-8-jdk

RUN \
  # install grail
  wget -q https://downloads.gradle.org/distributions/gradle-8.2.1-bin.zip && \
  unzip -d /opt/gradle gradle-8.2.1-bin.zip
ENV PATH=$PATH:/opt/gradle/gradle-8.2.1/bin

ENTRYPOINT [ "./start.sh" ]
