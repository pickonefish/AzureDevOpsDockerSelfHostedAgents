ARG OS_VERSION=ubuntu2004
ARG VERSION=3.239.1
FROM pickonefish/azure-devops-agent:${OS_VERSION}-${VERSION}

RUN apt-get update -y && apt-get upgrade -y
# Java / Apache Maven
RUN apt-get install openjdk-17-jdk openjdk-17-jre

# https://maven.apache.org/download.cgi
RUN apt install maven

ENTRYPOINT [ "./start.sh" ]
