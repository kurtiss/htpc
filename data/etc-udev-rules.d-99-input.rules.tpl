
SUBSYSTEM==input, GROUP=input, MODE=0660
KERNEL==tty[0-9]*, GROUP=tty, MODE=0660
{% for i, mount_key in environment('MOUNTS_') %}{% set mount = dict() %}{% for k, v in environment('MOUNT_' + mount_key + '_') %}{{ mount.__setitem__(k, v) or "" }}{% endfor %}KERNEL==sda, RUN+="/bin/mount {{ mount.MOUNTPOINT }}
{% endfor %}