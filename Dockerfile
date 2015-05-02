FROM resin/rpi-raspbian:wheezy
MAINTAINER kurtiss <kurtiss@gmail.com>

# baseimage - ENV
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# baseimage - add scripts
COPY baseimage /build

# baseimage - setup
RUN /build/prepare.sh && \
	/build/system_services.sh && \
	/build/utilities.sh

# kodi - update sources for kodi
ADD data/etc-apt-sources.list.d-mene.list /etc/apt/sources.list.d/mene.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
ADD data/etc-apt-sources.list.d-foundation.list /etc/apt/sources.list.d/foundation.list
RUN apt-key adv --fetch-keys http://archive.raspberrypi.org/debian/raspberrypi.gpg.key
RUN apt-get update

# kodi - add the input group for kodi/keyboard
RUN groupadd --system input

# kodi - install kodi
RUN apt-get install -y --no-install-recommends libgles2-mesa-dev libraspberrypi0 kodi

# x11
RUN apt-get install -y --no-install-recommends libgl1-mesa-dri xinit xserver-xorg xserver-xorg-video-fbturbo
RUN sed -i 's/allowed_users.*/allowed_users=anybody/g' /etc/X11/Xwrapper.config

# install config aids
RUN apt-get install -y --no-install-recommends python python-pip
RUN pip install envtpl

# sshd
RUN rm -f /etc/service/sshd/down
ENV SSH_AUTHORIZED_KEYS ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKWOZfnF9wAPYGj2tphIGeKT45YQomMcL/IMf6Rma1AySq6L4+3rJTN4EdMHAc5T2z1+7kDSPtf395c6mGNIZCx2aBdo3VcmbNLA7dZstPBEDfCw12GgA60xb85ep2wOq3MUjZZqRiJ0pB1VpMu1mI7phQf51SX290TTCnX+98PMu85F4qXfRCzfVJ6usvsuBZZESFt5xcpoZs/2H4pHzrKqh99QyihFNCrOq8hGF+T8cfDMxSRJbkVhu3LYU1TbF/xheU0b67WqIzZkPfZ8Qs23LZYlAO7RFl3LUmzkwDLMbRvK3V/bvs9pQjsXlw42qmL6AlfvZjwDMdDV5fvZcN
ADD data/root-ssh-authorized_keys.tpl /root/.ssh/authorized_keys.tpl
RUN envtpl /root/.ssh/authorized_keys.tpl

# further keyboard configuration
ADD data/etc-udev-rules.d-99-input.rules /etc/udev/rules.d/99-input.rules
ADD data/etc-udev-rules.d-10-permissions.rules /etc/udev/rules.d/10-permissions.rules

# usbmount
RUN apt-get install -y --no-install-recommends usbmount

# kodi - permissions
RUN chgrp video /dev/vchiq
RUN chmod 660 /dev/vchiq

RUN usermod -a -G audio kodi
RUN usermod -a -G video kodi
RUN usermod -a -G input kodi
RUN usermod -a -G dialout kodi
RUN usermod -a -G plugdev kodi
RUN usermod -a -G tty kodi

# TODO: kodi - init
# RUN mkdir -p /etc/service/kodi
# ADD data/etc-service-kodi-run /etc/service/kodi/run
# RUN chmod +x /etc/service/kodi/run

# configure kodi
# ADD data/usr-share-kodi-userdata-advancedsettings.xml /usr/share/kodi/userdata/advancedsettings.xml

RUN /build/cleanup.sh

CMD ["/sbin/my_init"]