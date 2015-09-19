#!/bin/bash


## Check and load custom directory and configuration
function loadconfig () {
	if [ -z "$1" ]
	then
		echo "[ERROR] First argument needs to point to custom directory with a config file."
		exit 1
	fi

	CUSTOM_DIR=$(cd $(dirname "$1") && pwd -P)/$(basename "$1")

	if [ ! -d "${CUSTOM_DIR}" ]
	then
		echo "[ERROR] Directory ${CUSTOM_DIR} not found."
		exit 1
	fi

	## Check config file
	CONFIG_FILE="${CUSTOM_DIR}/config"

	if [ ! -f "${CONFIG_FILE}" ]
	then
		echo "[ERROR] Config file ${CONFIG_FILE} not found."
		exit 1
	fi

	## Load configuration
	source "${CONFIG_FILE}"
}
