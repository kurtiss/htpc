FROM resin/rpi-raspbian:wheezy
MAINTAINER kurtiss <kurtiss@gmail.com>

RUN deb http://archive.mene.za.net/raspbian wheezy contrib
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
RUN apt-get update
RUN apt-get install -qy kodi