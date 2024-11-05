#!/bin/bash

# shellcheck source=../vault/un-encrypted/.env
source ./vault/un-encrypted/.env || echo "No .env file found, skipping"

# The directory where the decrypted vault files will be stored
DECRYPTED_DIR="vault/un-encrypted"

VAULT="$1"

# The directory where the encrypted vault files are stored
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

# Execute the vault password script with the environment argument and store the output in the temporary file
bash -c "$VAULT_PASSWORD_SCRIPT $VAULT" | tr -d '\n' >"$TEMP_VAULT_PASS_FILE"

# Check if the encrypted vault file exists
if [ -f "$ENCRYPTED_DIR/$VAULT.yml" ]; then
    # Decrypt the file and move it to the vault/un-encrypted/ directory
    if ansible-vault decrypt --vault-id "$VAULT" --output "$DECRYPTED_DIR/$VAULT.yml" --vault-password-file="$TEMP_VAULT_PASS_FILE" "$ENCRYPTED_DIR/$VAULT.yml" >/dev/null 2>&1; then
        echo "File decrypted successfully and stored in $DECRYPTED_DIR/$VAULT.yml"
    else
        echo "Failed to decrypt the file."
    fi
else
    echo "The file $ENCRYPTED_DIR/$VAULT.yml does not exist."
fi

if find "inventory/$VAULT/host_vars" -not -path '*/un-encrypted/*' -type f -name vault.yml -print -quit | grep -q 'vault.yml'; then
    # Encrypt the host vaults
    find "inventory/$VAULT/host_vars" -not -path '*/un-encrypted/*' -type f -name vault.yml | while read -r host; do
        # add un-encrypted/ to the path
        decrypted_dir=$(sed 's/\/vault.yml/\/un-encrypted\/vault.yml/' <<<"$host")

        if ansible-vault decrypt --vault-id "$VAULT" --output "${decrypted_dir}" --vault-password-file="$TEMP_VAULT_PASS_FILE" "$host" >/dev/null 2>&1; then
            echo "Host vault decrypted successfully and stored in ${host/vault.yml/un-encrypted\/vault.yml}"
        else
            echo "Failed to decrypt the host vault."
        fi
    done
fi
