#!/bin/bash

# shellcheck source=../vault/un-encrypted/.env
source ./vault/un-encrypted/.env || echo "No .env file found, skipping"

# Check if two arguments are passed to the script
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <playbook-name.yml> <environment> [additional-ansible-flags](optional)"
    exit 1
fi

DEBUG_FLAG=false

# Assign arguments to variables
PLAYBOOK_NAME="$1"
ENVIRONMENT="$2"
if [ "$ENVIRONMENT" == "production" ]; then
    ansible_flags=""
else
    ansible_flags=""
fi

# Check if the third argument contains --debug, -v, or -d
if [[ "$3" == *"--debug"* ]] || [[ "$3" == *"-v"* ]] || [[ "$3" == *"-d"* ]]; then
    DEBUG_FLAG=true
fi

if [ "$#" -eq 3 ]; then
    CLI_ADDITIONAL_FLAGS="$3"
else
    CLI_ADDITIONAL_FLAGS=""
fi

if [ -n "$CLI_ADDITIONAL_FLAGS" ]; then
    printf "Additional flags: %s\n\n" "$CLI_ADDITIONAL_FLAGS"
fi

## check if the environment vault exists, and if not create it
if [ ! -f "vault/$ENVIRONMENT.yml" ]; then
    if [ ! -f "vault/un-encrypted/$ENVIRONMENT.yml" ]; then
        echo "No vault found for $ENVIRONMENT environment, please create one"
        return 100
    else
        echo "Un-encrypted vault found for $ENVIRONMENT environment, encrypting vault"
        ./scripts/encrypt-vault.sh "$ENVIRONMENT"
    fi
elif [ -f "vault/un-encrypted/$ENVIRONMENT.yml" ]; then
    echo "Un-encrypted vault found for $ENVIRONMENT environment, updating vault"
    ./scripts/encrypt-vault.sh "$ENVIRONMENT"
fi

# Generate a temporary file for the vault password
TEMP_VAULT_PASS_FILE=$(mktemp vault-pass.tmp.XXXX -p /tmp)

# Ensure the temporary file is removed on script exit or if any signals are received
trap 'rm -f "$TEMP_VAULT_PASS_FILE"' EXIT SIGINT SIGTERM

# Execute the vault password script with the environment argument and store the output in the temporary file
./scripts/open-vault.sh "$ENVIRONMENT" >"$TEMP_VAULT_PASS_FILE"

# Add the necessary flags to the ansible command
ADDITIONAL_ANSIBLE_FLAGS=()
ADDITIONAL_ANSIBLE_FLAGS+=("-i=inventory/$ENVIRONMENT/hosts")
ADDITIONAL_ANSIBLE_FLAGS+=("--vault-id=${ENVIRONMENT}@${TEMP_VAULT_PASS_FILE}")
# Only add CLI_ADDITIONAL_FLAGS if it is not empty
if [ -n "$CLI_ADDITIONAL_FLAGS" ]; then
    ADDITIONAL_ANSIBLE_FLAGS+=("$CLI_ADDITIONAL_FLAGS")
fi

# only add ansible flags if they are not empty
if [ -n "$ansible_flags" ]; then
    ADDITIONAL_ANSIBLE_FLAGS+=("$ansible_flags")
fi

# Concatenate all flags into a single string
ALL_FLAGS=$(printf " %s" "${ADDITIONAL_ANSIBLE_FLAGS[@]}")

# Output command to be executed
printf "\n/opt/ansible/bin/ansible-playbook %s%s \n\n" "$PLAYBOOK_NAME" "$ALL_FLAGS"

if [ "$DEBUG_FLAG" = true ]; then
    printf "Debug flag: %s\n\n" "$DEBUG_FLAG"
    printf "Temp vault file: %s contains: %s\n\n" "$TEMP_VAULT_PASS_FILE" "$(cat "$TEMP_VAULT_PASS_FILE")"
fi

# sudo find /tmp -type f -name "vault-pass.tmp*"

# printf "\n\n\n"

# Run your ansible playbook with the temporary vault password file
ansible-playbook "$PLAYBOOK_NAME" "${ADDITIONAL_ANSIBLE_FLAGS[@]}"

# The temporary file will be removed automatically due to the trap command

# ansible localhost -m ansible.builtin.debug -a var="ixr1_kcmi_core_ansible_user" -e "@vars.yml" --vault-id dev@prompt
