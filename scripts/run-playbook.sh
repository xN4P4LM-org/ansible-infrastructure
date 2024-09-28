#!/bin/bash

# shellcheck source=../vault/un-encrypted/.env
source ./vault/un-encrypted/.env || echo "No .env file found, skipping"

# Check if two arguments are passed to the script
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <playbook-name.yml> <environment> [additional-ansible-flags](optional)"
    exit 1
fi

# Assign arguments to variables
PLAYBOOK_NAME="$1"
ENVIRONMENT="$2"
# if [ "$ENVIRONMENT" == "production" ]; then
#     ansible_flags=""
# else
#     ansible_flags="-vvv"
# fi
ADDITIONAL_ANSIBLE_FLAGS="$3"

## check if the environment vault exists, and if not create it
if [ ! -f "vault/$ENVIRONMENT.yml" ]; then
    echo "Creating vault for $ENVIRONMENT environment"
    ./scripts/encrypt-vault.sh "$ENVIRONMENT"
fi

# Path to your vault password script, adjust if necessary
VAULT_PASSWORD_SCRIPT="./scripts/open-vault.sh"

# Generate a temporary file for the vault password
TEMP_VAULT_PASS_FILE=$(mktemp)

# Ensure the temporary file is removed on script exit or if any signals are received
trap 'rm -f "$TEMP_VAULT_PASS_FILE"' EXIT SIGINT SIGTERM

# Execute the vault password script with the environment argument and store the output in the temporary file
bash -c "$VAULT_PASSWORD_SCRIPT $ENVIRONMENT" >"$TEMP_VAULT_PASS_FILE"

# Run your ansible playbook with the temporary vault password file
ansible-playbook "$PLAYBOOK_NAME" -i "inventory/$ENVIRONMENT/hosts" --vault-password-file "$TEMP_VAULT_PASS_FILE" $ADDITIONAL_ANSIBLE_FLAGS

# The temporary file will be removed automatically due to the trap command
