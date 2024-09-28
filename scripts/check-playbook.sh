#!/bin/bash

# Check if two arguments are passed to the script
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <playbook-name.yml> <environment>"
    exit 1
fi

# Assign arguments to variables
PLAYBOOK_NAME=$1
ENVIRONMENT=$2

# Path to your vault password script, adjust if necessary
VAULT_PASSWORD_SCRIPT="./scripts/open-vault.sh"

# Generate a temporary file for the vault password
TEMP_VAULT_PASS_FILE=$(mktemp)

# Ensure the temporary file is removed on script exit or if any signals are received
trap "rm -f $TEMP_VAULT_PASS_FILE" EXIT SIGINT SIGTERM

# Execute the vault password script with the environment argument and store the output in the temporary file
bash -c "$VAULT_PASSWORD_SCRIPT $ENVIRONMENT" > $TEMP_VAULT_PASS_FILE

# Run your ansible playbook with the temporary vault password file
ansible-playbook $PLAYBOOK_NAME -i inventory/$ENVIRONMENT/hosts --syntax-check --vault-password-file $TEMP_VAULT_PASS_FILE

# The temporary file will be removed automatically due to the trap command
