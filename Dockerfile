FROM jetbrains/teamcity-agent:2020.1.4-linux-sudo

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
RUN sudo sh -c 'echo deb https://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list'

RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -

# https://github.com/AdoptOpenJDK/openjdk-docker/blob/master/12/jdk/ubuntu/Dockerfile.hotspot.releases.full
RUN sudo apt-get update && \
    sudo apt-get install -y ffmpeg gnupg2 git sudo kubectl nodejs wget \
    binfmt-support qemu-user-static
    
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
RUN sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' && \
    sudo apt-get update && \
    sudo apt install -y cmake build-essential
RUN curl -Lso /tmp/openjdk.tar.gz https://github.com/AdoptOpenJDK/openjdk12-binaries/releases/download/jdk-12.0.2%2B10/OpenJDK12U-jdk_x64_linux_hotspot_12.0.2_10.tar.gz && \
    cd /tmp && \
    tar -xf /tmp/openjdk.tar.gz && \
    rm /tmp/openjdk.tar.gz && \
    sudo mkdir -p /usr/lib/jvm/jdk-12 && \
    sudo mv jdk-12*/* /usr/lib/jvm/jdk-12/ && \
    sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk-12/bin/java" 1020 && \
    sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk-12/bin/javac" 1020
RUN curl -Lso /tmp/openjdk.tar.gz https://github.com/AdoptOpenJDK/openjdk13-binaries/releases/download/jdk-13.0.2%2B8/OpenJDK13U-jdk_x64_linux_hotspot_13.0.2_8.tar.gz && \
    cd /tmp && \
    tar -xf /tmp/openjdk.tar.gz && \
    rm /tmp/openjdk.tar.gz && \
    sudo mkdir -p /usr/lib/jvm/jdk-13 && \
    sudo mv jdk-13*/* /usr/lib/jvm/jdk-13/ && \
    sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk-13/bin/java" 1040 && \
    sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk-13/bin/javac" 1040

# install helm
RUN curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > /tmp/install-helm.sh
RUN chmod u+x /tmp/install-helm.sh && \
    sudo /tmp/install-helm.sh && \
    rm -f /tmp/install-helm.sh

# Trigger .NET CLI first run experience by running arbitrary cmd to populate local package cache
RUN sudo dotnet help

ENV JAVA_TOOL_OPTIONS ""

RUN curl -Ls https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
	
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

RUN sudo apt-get update && sudo apt-get install -y mongodb-org-shell 
