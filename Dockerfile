FROM resin/rpi-raspbian:wheezy
MAINTAINER kurtiss <kurtiss@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

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
RUN apt-get install -qy vim openssh-server

# configure sshd
ENV SSHD_PORT 2222
ADD data/etc-ssh-sshd_config.tpl /etc/ssh/sshd_config.tpl
RUN envtpl /etc/ssh/sshd_config.tpl

ENV SSH_AUTHORIZED_KEYS ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKWOZfnF9wAPYGj2tphIGeKT45YQomMcL/IMf6Rma1AySq6L4+3rJTN4EdMHAc5T2z1+7kDSPtf395c6mGNIZCx2aBdo3VcmbNLA7dZstPBEDfCw12GgA60xb85ep2wOq3MUjZZqRiJ0pB1VpMu1mI7phQf51SX290TTCnX+98PMu85F4qXfRCzfVJ6usvsuBZZESFt5xcpoZs/2H4pHzrKqh99QyihFNCrOq8hGF+T8cfDMxSRJbkVhu3LYU1TbF/xheU0b67WqIzZkPfZ8Qs23LZYlAO7RFl3LUmzkwDLMbRvK3V/bvs9pQjsXlw42qmL6AlfvZjwDMdDV5fvZcN kurtiss
ADD data/root-ssh-authorized_keys.tpl /root/.ssh/authorized_keys.tpl
RUN envtpl /root/.ssh/authorized_keys.tpl

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

# add root to necessary groups -- this may not be necessary
RUN usermod -a -G audio root
RUN usermod -a -G video root
RUN usermod -a -G input root
RUN usermod -a -G dialout root
RUN usermod -a -G plugdev root
RUN usermod -a -G tty root

# configure kodi
ADD data/usr-share-kodi-userdata-advancedsettings.xml /usr/share/kodi/userdata/advancedsettings.xml

CMD ["/usr/bin/kodi-standalone"]