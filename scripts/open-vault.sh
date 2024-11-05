#!/bin/bash

# Create intermediate environemnt
environemnt=$1

# Dynamically construct the environment variable name and get its value
vault_password=$(printenv "${environemnt^^}"_VAULT_PASSWORD)

# Print the value of the environment variable
printf "%s" "$vault_password"
