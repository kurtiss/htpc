#!/bin/bash

export PYLOAD_USERNAME=pyload
export PYLOAD_PASSWORD=pyload

# Set username and password
expect <<"EOF"
    set timeout -1
    spawn python /root/pyload/pyLoadCore.py --configdir=/root/.pyload/config -u
    expect -re ".*: "
    send "1\r"
    expect -re ".*: "
    send "$env(PYLOAD_USERNAME)\r"
    expect -re ".*: "
    send "$env(PYLOAD_PASSWORD)\r"
    expect -re ".*: "
    send "$env(PYLOAD_PASSWORD)\r"
    expect -re ".*: "
    send "4\r"
    expect eof
EOF

unset PYLOAD_USERNAME
unset PYLOAD_PASSWORD