#!/bin/bash

# The name of the file to decrypt, passed as the first argument to the script
VAULT_FILE_NAME=$1

# The directory where the encrypted vault files are stored
ENCRYPTED_DIR="vault"

# The directory where the decrypted vault files will be stored
DECRYPTED_DIR="vault/un-encrypted"

if [ ! -d $DECRYPTED_DIR ]; then
    mkdir $DECRYPTED_DIR
fi

# Check if the encrypted vault file exists
if [ -f "$ENCRYPTED_DIR/$VAULT_FILE_NAME.yml" ]; then
    # Decrypt the file and move it to the vault/un-encrypted directory
    ansible-vault decrypt "$ENCRYPTED_DIR/$VAULT_FILE_NAME.yml" --output "$DECRYPTED_DIR/$VAULT_FILE_NAME.yml" --vault-password-file <(bash -c "./scripts/open-vault.sh $1")
    if [ $? -eq 0 ]; then
        echo "File decrypted successfully and stored in $DECRYPTED_DIR/$VAULT_FILE_NAME.yml"
    else
        echo "Failed to decrypt the file."
    fi
else
    echo "The file $ENCRYPTED_DIR/$VAULT_FILE_NAME.yml does not exist."
fi
