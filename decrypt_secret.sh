#!/bin/sh

# Decrypt the file
# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$PASSPHRASE" \
--output api_key.txt api_key.txt.gpg