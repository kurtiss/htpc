FROM resin/rpi-raspbian:wheezy
MAINTAINER kurtiss <kurtiss@gmail.com>

# baseimage - ENV
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# baseimage - add scripts
COPY baseimage /build

# baseimage - setup
RUN /build/prepare.sh
RUN /build/system_services.sh

# runit, dammit
RUN sed 'p; s/deb /deb-src /' /etc/apt/sources.list | uniq > /etc/apt/sources.list.new && \
	mv -f /etc/apt/sources.list.new /etc/apt/sources.list
RUN apt-get update
RUN apt-get build-dep -y runit
RUN sudo apt-get source runit
# RUN sudo dpkg -i runit*.deb
# RUN sudo rm -rf runit*

# RUN /build/system_services2.sh
# RUN /build/utilities.sh
# RUN /build/cleanup.sh

# kodi - update sources for kodi
# ADD data/etc-apt-sources.list.d-mene.list /etc/apt/sources.list.d/mene.list
# RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED

# kodi - add the input group for kodi/keyboard
# RUN groupadd --system input

# system - update package lists - already accomplished by baseimage
# RUN apt-get update

# kodi - install kodi
# RUN apt-get install -qy --no-install-recommends libgles2-mesa-dev libraspberrypi0 kodi

# install config aids
# RUN apt-get install -qy python python-pip
# RUN pip install envtpl

# TODO: sshd - configure authorized keys
# ENV SSH_AUTHORIZED_KEYS ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKWOZfnF9wAPYGj2tphIGeKT45YQomMcL/IMf6Rma1AySq6L4+3rJTN4EdMHAc5T2z1+7kDSPtf395c6mGNIZCx2aBdo3VcmbNLA7dZstPBEDfCw12GgA60xb85ep2wOq3MUjZZqRiJ0pB1VpMu1mI7phQf51SX290TTCnX+98PMu85F4qXfRCzfVJ6usvsuBZZESFt5xcpoZs/2H4pHzrKqh99QyihFNCrOq8hGF+T8cfDMxSRJbkVhu3LYU1TbF/xheU0b67WqIzZkPfZ8Qs23LZYlAO7RFl3LUmzkwDLMbRvK3V/bvs9pQjsXlw42qmL6AlfvZjwDMdDV5fvZcN kurtiss

# further keyboard configuration
# ADD data/etc-udev-rules.d-99-input.rules /etc/udev/rules.d/99-input.rules
# ADD data/etc-udev-rules.d-10-permissions.rules /etc/udev/rules.d/10-permissions.rules

# add kodi to necessary groups
# RUN usermod -a -G audio kodi
# RUN usermod -a -G video kodi
# RUN usermod -a -G input kodi
# RUN usermod -a -G dialout kodi
# RUN usermod -a -G plugdev kodi
# RUN usermod -a -G tty kodi

# configure kodi
# ADD data/usr-share-kodi-userdata-advancedsettings.xml /usr/share/kodi/userdata/advancedsettings.xml

# Clean up APT when done.
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# CMD ["/sbin/my_init"]
CMD ["/bin/bash"]