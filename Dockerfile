FROM resin/rpi-raspbian:wheezy
MAINTAINER kurtiss <kurtiss@gmail.com>

ADD data/etc-apt-sources.list.d-mene.list /etc/apit/sources.list.d/mene.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
RUN apt-get update
RUN apt-get install -qy kodi