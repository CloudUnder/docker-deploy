#!/bin/bash

source functions.sh
loadconfig $1

SSH_PRIVATE_KEY="${CUSTOM_DIR}/id_rsa"
SSH_PUBLIC_KEY="${SSH_PRIVATE_KEY}.pub"


## Check if key already exists
if [ -f "${SSH_PRIVATE_KEY}" ]
then
	echo "[ERROR] SSH key ${SSH_PRIVATE_KEY} already exists."
	echo "If you really want to generate a new key, remove existing key first."
	exit 1
fi


## Generate new deployment key
ssh-keygen -t rsa -b ${SSH_KEY_SIZE} -N "" -C "${SSH_KEY_IDENTIFIER}" -f ${SSH_PRIVATE_KEY}


## Check if key already exists
if [ -f "${SSH_PUBLIC_KEY}" ]
then
	echo "You can now add the public key to ~/.ssh/authorized_keys on the remote SSH host and your private Git repoitory as a deployment key."
	echo "Public key file: ${SSH_PUBLIC_KEY}"
	exit 1
fi
