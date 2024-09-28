#!/bin/bash

# The directory where the un-encrypted vault files are stored
UNENCRYPTED_DIR="vault/un-encrypted"

# The directory where the encrypted vault files will be stored
ENCRYPTED_DIR="vault"

# Check if the un-encrypted vault file exists
if [ -f "$UNENCRYPTED_DIR/$1.yml" ]; then
    # Encrypt the file and move it to the vault/ directory
    ansible-vault encrypt --vault-id $1 "$UNENCRYPTED_DIR/$1.yml" --output "$ENCRYPTED_DIR/$1.yml" --vault-password-file <(bash -c "./scripts/open-vault.sh $1")
    if [ $? -eq 0 ]; then
        echo "File encrypted successfully and stored in $ENCRYPTED_DIR/$1.yml"
    else
        echo "Failed to encrypt the file."
    fi
else
    echo "The file $UNENCRYPTED_DIR/$1.yml does not exist."
fi
