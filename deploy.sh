#!/bin/bash

if [ -z "$1" ]
then
	echo "Run with option -h for some help."
	exit 1
fi



## Set defaults
COMMIT="HEAD"


## Read options to override defaults
while getopts ":c:h" opt; do
	case $opt in
		h)
			echo "Usage: deploy.sh [-h] [-c commit-id] config-dir"
			echo "    -h: Help"
			echo "    -c commit-id: Specify a certain commit ID (default: HEAD)."
			echo "    config-dir: The directory containing the config file."
			exit 0;
			;;
		c)
			COMMIT="$OPTARG"
			;;
		\?)
			echo "Illegal option -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

shift $((OPTIND-1))



## Load functions and configuration
source functions.sh
loadconfig $1


## Create volume container
docker create --name ${VOLUME_NAME} ${IMAGE_VOLUME} /bin/true

if [ $? -ne 0 ]
then
	exit 1
fi


## Clone source from repository
if [ "${DO_GIT_CLONE}" = true ]
then
	docker run --rm \
		-e "REPOSITORY=${REPOSITORY}" \
		-e "BRANCH=${BRANCH}" \
		-e "COMMIT=${COMMIT}" \
		--volumes-from ${VOLUME_NAME} \
		-v ${CUSTOM_DIR}:/custom:ro \
		${IMAGE_GITCLONE}

	if [ $? -ne 0 ]
	then
		exit 1
	fi
fi


## Run custom build scripts using custom Docker images
if [ "${DO_BUILD}" = true ]
then
	docker run --rm \
		--volumes-from ${VOLUME_NAME} \
		-v ${CUSTOM_DIR}:/custom:ro \
		${IMAGE_BUILDER} \
		bash -c 'source ~/.nvm/nvm.sh ; source /custom/build.sh'

	if [ $? -ne 0 ]
	then
		exit 1
	fi
fi


## Run deployment
if [ "${DO_DEPLOY}" = true ]
then
	docker run --rm \
		--volumes-from ${VOLUME_NAME} \
		-v ${CUSTOM_DIR}:/custom:ro \
		${IMAGE_DEPLOYER} \
		bash -c 'cp /custom/id_rsa ~/.ssh/id_rsa ; /custom/deploy.sh'

	if [ $? -ne 0 ]
	then
		exit 1
	fi
fi


## Look into volume
# docker run --rm --volumes-from ${VOLUME_NAME} ubuntu:15.04 ls -lah /code
# docker run --rm --volumes-from ${VOLUME_NAME} ubuntu:15.04 ls -lah /build


## Remove volume container
echo "Finished. Removing Docker volume conatiner:"
docker rm -v ${VOLUME_NAME}

if [ $? -ne 0 ]
then
	exit 1
fi
