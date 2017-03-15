FROM       ubuntu:14.04
MAINTAINER Aleksandar Diklic "https://github.com/rastasheep"

# install supervisor, curl
RUN apt-get update && apt-get install -y supervisor curl

RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

## pipesocker install
RUN sudo apt-get -y install git make build-essential qt5-default qt5-qmake
RUN cd /tmp/
RUN git clone https://github.com/jedisct1/libsodium.git
RUN git clone https://github.com/pipesocks/pipesocks.git
RUN cd libsodium/
RUN git checkout stable
RUN ./configure
RUN make && sudo make install
RUN sudo cp /usr/local/lib/libsodium.so.18 /usr/lib/
RUN cd ../pipesocks/pipesocks/
RUN git checkout stable
RUN qmake server.pipesocks.pro && make
RUN sudo cp pipesocks /usr/bin/
RUN cd ../../
RUN sudo rm -R pipesocks/
RUN sudo rm -R libsodium/
###USAGE
##./pipesocks pump [-p Local Port] [-k Password]
##./pipesocks pipe <-H Remote Host> [-P Remote Port] [-p Local Port]
##./pipesocks tap <-H Remote Host> [-P Remote Port] [-p Local Port] [-k Password]
##

ADD pipe.conf /etc/supervisor/conf.d/pipe.conf

ENV SUPERNODE_PORT 8989
EXPOSE 9001
EXPOSE 8989
EXPOSE 22
EXPOSE 8000

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/pipe.conf"]
