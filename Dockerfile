FROM resin/rpi-raspbian:wheezy
MAINTAINER kurtiss <kurtiss@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# ENV SSHD_PORT 22

# update sources for kodi
ADD data/etc-apt-sources.list.d-mene.list /etc/apt/sources.list.d/mene.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED

# add the input group for kodi/keyboard
RUN groupadd --system input

# install kodi
RUN apt-get update
RUN apt-get install -qy libgles2-mesa-dev libraspberrypi0 kodi

# install config aids
RUN apt-get install -qy python python-pip
RUN pip install envtpl

# install development aids
RUN apt-get install vim openssh-server

# configure sshd
ADD data/etc-ssh-sshd_config.tpl /etc/ssh/sshd_config.tpl
RUN envtpl /etc/ssh/sshd_config.tpl

# further keyboard configuration
ADD data/etc-udev-rules.d-99-input.rules /etc/udev/rules.d/99-input.rules
ADD data/etc-udev-rules.d-10-permissions.rules /etc/udev/rules.d/10-permissions.rules

# add kodi to necessary groups
RUN usermod -a -G audio kodi
RUN usermod -a -G video kodi
RUN usermod -a -G input kodi
RUN usermod -a -G dialout kodi
RUN usermod -a -G plugdev kodi
RUN usermod -a -G tty kodi

# configure kodi
ADD data/usr-share-kodi-userdata-advancedsettings.xml /usr/share/kodi/userdata/advancedsettings.xml

CMD ["/usr/bin/kodi-standalone"]