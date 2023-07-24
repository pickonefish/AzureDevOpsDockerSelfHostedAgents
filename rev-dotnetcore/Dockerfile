ARG OS_VERSION=ubuntu18.04
ARG VERSION=1.0.0
FROM pickonefish/azure-devops-agent:${OS_VERSION}-docker-${VERSION}

# .net-core
# https://docs.microsoft.com/zh-tw/dotnet/core/install/linux-ubuntu#1804-
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb

RUN apt-get update
RUN apt-get install -y dotnet-sdk-6.0

ENTRYPOINT [ "./start.sh" ]
