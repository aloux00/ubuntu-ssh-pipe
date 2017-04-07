FROM       ubuntu:14.04
MAINTAINER Aleksandar Diklic "https://github.com/rastasheep"

# install supervisor, curl
RUN apt-get update -y && \
    apt-get install -y supervisor openssh-server curl xz-utils && \
    curl -SL https://github.com/pipesocks/pipesocks/releases/download/$version/pipesocks-$version-linux.tar.xz | \
    tar -xJ && \
    apt-get remove -y curl xz-utils && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir /var/run/sshd

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

## pipesocker install
ENV version=2.3 \
    type=pump \
    remotehost="" \
    remoteport=7473 \
    localport=7473 \
    password=""
##RUN apt-get update -y && \
    ##apt-get install -y curl xz-utils && \
    ##curl -SL https://github.com/pipesocks/pipesocks/releases/download/$version/pipesocks-$version-linux.tar.xz | \
    ##tar -xJ && \
    ##apt-get remove -y curl xz-utils && \
    ##apt-get autoremove -y && \
    ##rm -rf /var/lib/apt/lists/*
EXPOSE $localport
###USAGE
##./pipesocks pump [-p Local Port] [-k Password]
##./pipesocks pipe <-H Remote Host> [-P Remote Port] [-p Local Port]
##./pipesocks tap <-H Remote Host> [-P Remote Port] [-p Local Port] [-k Password]
##
ADD supernode /usr/bin/supernode
ADD edge /usr/bin/edge
RUN chmod 777 /usr/bin/supernode && chmod 777 /usr/bin/edge
ADD pipe.conf /etc/supervisor/conf.d/pipe.conf

ENV SUPERNODE_PORT 16565
EXPOSE 9001
EXPOSE 16565
EXPOSE 22
EXPOSE 8000

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/pipe.conf"]
