{% for i, mount_key in environment('MOUNTS_') %}{% set mount = dict() %}{% for k, v in environment('MOUNT_' + mount_key + '_') %}{{ mount.__setitem__(k, v) or "" }}{% endfor %}SUBSYSTEM=="block", ATTRS{serial}=="{{ mount.SERIAL }}", ACTION=="add", RUN+="/etc/udev/rules.d/mount.sh {{ mount.LABEL }}"
{% endfor %}