#!/bin/bash

cwd=$(pwd)

# exit on error
set -e
ansible_flags=()
default_ansible_playbook="common.yml"

# Assign arguments to variables
ENVIRONMENT="$1"
# if [ "$ENVIRONMENT" == "production" ]; then
#     ansible_flags=""
# else
#     ansible_flags="-vvv"
# fi
ADDITIONAL_ANSIBLE_FLAGS="${2:-""}"

if [ "$ADDITIONAL_ANSIBLE_FLAGS" != "" ]; then
    ansible_flags+=("$ADDITIONAL_ANSIBLE_FLAGS")
fi

ansible_flags+=(-i "inventory/$ENVIRONMENT/hosts")
ansible_flags+=(--ask-become-pass)

# Run your ansible playbook with the temporary vault password file
ansible-playbook "$cwd/$default_ansible_playbook" "${ansible_flags[@]}"