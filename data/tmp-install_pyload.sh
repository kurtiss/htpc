#!/bin/bash

: ${PYLOAD_USERNAME?"PYLOAD_USERNAME must be defined."}
: ${PYLOAD_PASSWORD?"PYLOAD_PASSWORD must be defined."}

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