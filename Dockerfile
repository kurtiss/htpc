FROM resin/rpi-raspbian:wheezy
MAINTAINER kurtiss <kurtiss@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

ADD data/etc-apt-sources.list.d-mene.list /etc/apt/sources.list.d/mene.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
RUN apt-get update
RUN apt-get install -qy libgles2-mesa-dev libraspberrypi0 kodi

CMD ["/usr/bin/kodi"]