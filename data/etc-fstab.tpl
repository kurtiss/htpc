{% for i, mount_key in environment('MOUNTS_') %}{% set mount = dict() %}{% for k, v in environment('MOUNT_' + mount_key + '_') %}{{ mount.__setitem__(k, v) or "" }}{% endfor %}UUID={{ mount.UUID }} /mnt/{{ mount.LABEL }} {{ mount.FSTAB }}
{% endfor %}