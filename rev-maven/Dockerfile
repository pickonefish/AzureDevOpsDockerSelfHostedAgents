ARG OS_VERSION=ubuntu18.04
ARG VERSION=1.0.0
FROM pickonefish/azure-devops-agent:${OS_VERSION}-${VERSION}

RUN apt-get update

# Java / Apache Maven
RUN apt-get install openjdk-17-jdk

# https://maven.apache.org/download.cgi
RUN apt install maven

ENTRYPOINT [ "./start.sh" ]
