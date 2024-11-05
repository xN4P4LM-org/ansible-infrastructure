#!/bin/bash

if [ -d /opt/ansible ]; then
    echo "Ansible already installed"
    exit 0
fi

python3 -m venv /opt/ansible

/opt/ansible/bin/pip install --upgrade pip
/opt/ansible/bin/pip install ansible

ln -s /opt/ansible/bin/ansible* /usr/bin/
