#!/bin/bash

# shellcheck source=../vault/un-encrypted/.env
source ./vault/un-encrypted/.env || echo "No .env file found, skipping"

# The directory where the un-encrypted vault files are stored
UNENCRYPTED_DIR="vault/un-encrypted"

VAULT="$1"

# The directory where the encrypted vault files will be stored
ENCRYPTED_DIR="vault"

if [ -z "$VAULT" ]; then
    echo "Usage: $0 <vault-name>"
    exit 1
fi

# Generate a temporary file for the vault password
TEMP_VAULT_PASS_FILE=$(mktemp vault-pass.tmp.XXXX -p /tmp)

# Ensure the temporary file is removed on script exit or if any signals are received
trap 'rm -f "$TEMP_VAULT_PASS_FILE"' EXIT SIGINT SIGTERM

# Execute the vault password script with the environment argument and store the output in the temporary file
./scripts/open-vault.sh "$VAULT" >"$TEMP_VAULT_PASS_FILE"

printf "Using vault file: %s containing passwd: %s\n\n" "$TEMP_VAULT_PASS_FILE" "$(cat "$TEMP_VAULT_PASS_FILE")"

# Check if the un-encrypted vault file exists
if [ -f "$UNENCRYPTED_DIR/$VAULT.yml" ]; then

    rm -f "$ENCRYPTED_DIR/$VAULT.yml"

    # Encrypt the file and move it to the vault/ directory
    if ansible-vault encrypt --vault-id="$VAULT@$TEMP_VAULT_PASS_FILE" --output "$ENCRYPTED_DIR/$VAULT.yml" "$UNENCRYPTED_DIR/$VAULT.yml"; then
        echo "File encrypted successfully and stored in $ENCRYPTED_DIR/$VAULT.yml"
    else
        echo "Failed to encrypt the file."
    fi
else
    echo "The file $UNENCRYPTED_DIR/$VAULT.yml does not exist."
fi

# Check if host vaults exist, and if so encrypt them
if find "inventory/$VAULT/host_vars" -path '*/un-encrypted/*' -type f -name vault.yml -print -quit | grep -q 'vault.yml'; then
    # Encrypt the host vaults
    find "inventory/$VAULT/host_vars" -path '*/un-encrypted/*' -type f -name vault.yml | while read -r host; do
        # remove un-encrypted/* from the path
        encrypted_dir=$(sed 's/un-encrypted\///' <<<"$host")

        rm -f "$encrypted_dir"

        if ansible-vault encrypt --vault-id="$VAULT@$TEMP_VAULT_PASS_FILE" --output "${encrypted_dir}" "$host"; then
            echo "Host vault encrypted successfully and stored in ${host/un-encrypted\//}"
        else
            echo "Failed to encrypt the host vault."
        fi
    done
fi
