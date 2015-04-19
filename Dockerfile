FROM resin/rpi-raspbian:wheezy
MAINTAINER kurtiss <kurtiss@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# kodi dependencies
ADD data/etc-apt-sources.list.d-mene.list /etc/apt/sources.list.d/mene.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
RUN apt-get update
RUN apt-get install -qy libgles2-mesa-dev libraspberrypi0 kodi

# keyboard configuration
RUN addgroup --system input
ADD data/etc-udev-rules.d-99-input.rules /etc/udev/rules.d/99-input.rules
ADD data/etc-udev-rules.d-10-permissions.rules /etc/udev/rules.d/10-permissions.rules
RUN usermod -a -G input kodi

CMD ["/usr/bin/kodi"]