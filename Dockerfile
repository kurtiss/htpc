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
ADD data/root-ssh-authorized_keys.tpl /root/.ssh/authorized_keys.tpl

# udev configuration
ADD data/etc-udev-rules.d-99-input.rules.tpl /etc/udev/rules.d/99-input.rules.tpl
ADD data/etc-udev-rules.d-10-permissions.rules /etc/udev/rules.d/10-permissions.rules

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
RUN apt-get install -u --no-install-recommends usbutils

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
RUN touch /etc/sv/kodi/down
RUN ln -s /etc/sv/kodi /etc/service/kodi

# udevd - init
RUN mkdir -p /etc/sv/udevd
ADD data/etc-sv-udevd-run /etc/sv/udevd/run
RUN chmod +x /etc/sv/udevd/run
RUN mkdir -p /etc/sv/udevd/log
ADD data/etc-sv-udevd-log-run /etc/sv/udevd/log/run
RUN chmod +x /etc/sv/udevd/log/run
# RUN touch /etc/sv/udevd/down
RUN ln -s /etc/sv/udevd /etc/service/udevd

# udevinit - init
RUN mkdir -p /etc/sv/udevinit
ADD data/etc-sv-udevinit-run /etc/sv/udevinit/run
RUN chmod +x /etc/sv/udevinit/run
# RUN touch /etc/sv/udevinit/down
RUN ln -s /etc/sv/udevinit /etc/service/udevinit

# configure kodi
RUN sudo -u kodi sh -c "mkdir -p /home/kodi/.kodi/userdata"
ADD data/home-kodi-.kodi-userdata-advancedsettings.xml /home/kodi/.kodi/userdata/advancedsettings.xml
RUN chown kodi /home/kodi/.kodi/userdata/advancedsettings.xml
RUN chgrp nogroup /home/kodi/.kodi/userdata/advancedsettings.xml

# oninit
RUN mkdir -p /etc/my_init.d
ADD data/etc-my_init.d-onint /etc/my_init.d/oninit
RUN chmod +x /etc/my_init.d/oninit

RUN /build/cleanup.sh

CMD ["/sbin/my_init"]