#!/bin/bash

# run all scripts in the env directory

for script in scripts/env/*; do
  if [ -f $script -a -x $script ]; then
    echo "Running ansible for $script environment"
    $script
  fi
done 