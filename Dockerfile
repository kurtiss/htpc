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
RUN apt-get install -y --no-install-recommends python python-pip net-tools
RUN pip install envtpl

# sshd
RUN rm -f /etc/service/sshd/down
ADD data/root-ssh-authorized_keys.tpl /root/.ssh/authorized_keys.tpl

# udev configuration
ADD data/etc-udev-rules.d-99-input.rules /etc/udev/rules.d/99-input.rules
ADD data/etc-udev-rules.d-96-usb.rules.tpl /etc/udev/rules.d/96-usb.rules.tpl
ADD data/etc-udev-rules.d-10-permissions.rules /etc/udev/rules.d/10-permissions.rules
ADD data/etc-udev-rules.d-mount.sh /etc/udev/rules.d/mount.sh
RUN chmod +x /etc/udev/rules.d/mount.sh

# fstab
ADD data/etc-fstab.tpl /etc/fstab.tpl

# pyload - install dependencies
RUN apt-get install -y --no-install-recommends build-essential bsdtar expect gdebi git \
	libev-dev libffi-dev libssl-dev python-crypto python-dev python-pip python-pycurl \
	rhino tesseract-ocr unrar-free wget

# pyload - install pypi dependencies
RUN pip install Beaker BeautifulSoup bjoern bottle feedparser \
	https://pypi.python.org/packages/source/g/getch/getch-1.0-python2.tar.gz#md5=586ea0f1f16aa094ff6a30736ba03c50 \
	jinja2 MultipartPostHandler pillow pyOpenSSL simplejson thrift

# pyload - install
RUN mkdir -p /root/pyload && wget -qO- http://download.pyload.org/pyload-src-v0.4.9.zip | bsdtar -xvf- -C /root
ADD data/root-.pyload-config /root/.pyload/config

# pyload - init
RUN mkdir -p /etc/sv/pyload
ADD data/etc-sv-pyload-run /etc/sv/pyload/run
RUN chmod +x /etc/sv/pyload/run
RUN ln -s /etc/sv/pyload /etc/service/pyload

# usbutils
RUN apt-get install -y --no-install-recommends usbutils ntfs-3g

# nfs
RUN apt-get install -y --no-install-recommends netbase ifupdown nfs-common nfs-kernel-server

# kodi - permissions
RUN usermod -a -G audio kodi
RUN usermod -a -G video kodi
RUN usermod -a -G input kodi
RUN usermod -a -G dialout kodi
RUN usermod -a -G plugdev kodi
RUN usermod -a -G tty kodi

# kodi - init
RUN mkdir -p /etc/sv/kodi
ADD data/etc-sv-kodi-run /etc/sv/kodi/run
RUN chmod +x /etc/sv/kodi/run
RUN ln -s /etc/sv/kodi /etc/service/kodi

# networking - init
RUN mkdir -p /etc/sv/networking
ADD data/etc-sv-networking-run /etc/sv/networking/run
RUN chmod +x /etc/sv/networking/run
ADD data/etc-sv-networking-finish /etc/sv/networking/finish
RUN chmod +x /etc/sv/networking/finish
RUN ln -s /etc/sv/networking /etc/service/networking

# rpcbind
RUN mkdir -p /etc/sv/rpcbind
ADD data/etc-sv-rpcbind-run /etc/sv/rpcbind/run
RUN chmod +x /etc/sv/rpcbind/run
RUN ln -s /etc/sv/rpcbind /etc/service/rpcbind

# statd
RUN mkdir -p /etc/sv/statd
RUN touch /etc/sv/statd/down
ADD data/etc-sv-statd-run /etc/sv/statd/run
ADD data/etc-sv-statd-finish /etc/sv/statd/finish
RUN chmod +x /etc/sv/statd/run
RUN chmod +x /etc/sv/statd/finish
RUN ln -s /etc/sv/statd /etc/service/statd

# idmapd
RUN mkdir -p /etc/sv/idmapd
RUN touch /etc/sv/idmapd/down
ADD data/etc-sv-idmapd-run /etc/sv/idmapd/run
RUN chmod +x /etc/sv/idmapd/run
RUN ln -s /etc/sv/idmapd /etc/service/idmapd

# gssd
RUN mkdir -p /etc/sv/gssd
RUN touch /etc/sv/gssd/down
ADD data/etc-sv-gssd-run /etc/sv/gssd/run
RUN chmod +x /etc/sv/gssd/run
RUN ln -s /etc/sv/gssd /etc/service/gssd

# nfs-common
RUN mkdir -p /etc/sv/nfs-common
RUN touch /etc/sv/nfs-common/down
ADD data/etc-sv-nfs-common-common /etc/sv/nfs-common/common
ADD data/etc-sv-nfs-common-run /etc/sv/nfs-common/run
ADD data/etc-sv-nfs-common-finish /etc/sv/nfs-common/finish
RUN chmod +x /etc/sv/nfs-common/run
RUN chmod +x /etc/sv/nfs-common/finish
RUN ln -s /etc/sv/nfs-common /etc/service/nfs-common

# nfs-kernel-server
RUN mkdir -p /etc/sv/nfs-kernel-server
ADD data/etc-sv-nfs-kernel-server-common /etc/sv/nfs-kernel-server/common
ADD data/etc-sv-nfs-kernel-server-run /etc/sv/nfs-kernel-server/run
ADD data/etc-sv-nfs-kernel-server-finish /etc/sv/nfs-kernel-server/finish
RUN chmod +x /etc/sv/nfs-kernel-server/run
RUN chmod +x /etc/sv/nfs-kernel-server/finish
RUN ln -s /etc/sv/nfs-kernel-server /etc/service/nfs-kernel-server

# mountd
RUN mkdir -p /etc/sv/mountd
RUN touch /etc/sv/mountd/down
ADD data/etc-sv-mountd-run /etc/sv/mountd/run
RUN chmod +x /etc/sv/mountd/run
RUN ln -s /etc/sv/mountd /etc/service/mountd

# udevd - init
# RUN mkdir -p /etc/sv/udevd
# ADD data/etc-sv-udevd-run /etc/sv/udevd/run
# RUN chmod +x /etc/sv/udevd/run
# RUN ln -s /etc/sv/udevd /etc/service/udevd

# configure kodi
RUN sudo -u kodi sh -c "mkdir -p /home/kodi/.kodi/userdata"
ADD data/home-kodi-.kodi-userdata-advancedsettings.xml /home/kodi/.kodi/userdata/advancedsettings.xml
RUN chown kodi /home/kodi/.kodi/userdata/advancedsettings.xml
RUN chgrp nogroup /home/kodi/.kodi/userdata/advancedsettings.xml

# oninit
RUN mkdir -p /etc/my_init.d
ADD data/etc-my_init.d-oninit /etc/my_init.d/oninit
RUN chmod +x /etc/my_init.d/oninit

RUN /build/cleanup.sh

# empty
CMD ["/sbin/my_init"]
