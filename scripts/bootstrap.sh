#!/bin/bash

cwd=$(pwd)

# exit on error
set -e
ansible_flags=()
default_ansible_playbook="bootstrap.yml"

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <host>"
    exit 1
fi

# Assign arguments to variables
# ENVIRONMENT="$1"
# if [ "$ENVIRONMENT" == "production" ]; then
#     ansible_flags=""
# else
#     ansible_flags="-vvv"
# fi
ADDITIONAL_ANSIBLE_FLAGS="${2:-""}"

if [ "$ADDITIONAL_ANSIBLE_FLAGS" != "" ]; then
    ansible_flags+=("$ADDITIONAL_ANSIBLE_FLAGS")
fi

ansible_flags+=(-i "$1,")
ansible_flags+=(--ask-become-pass)

# Run your ansible playbook with the temporary vault password file
ansible-playbook "$cwd/$default_ansible_playbook" "${ansible_flags[@]}"
