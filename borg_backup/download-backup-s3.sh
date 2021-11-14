#!/usr/bin/env bash

bold=$(tput bold)
normal=$(tput sgr0)
accent=$(tput setaf 99)
secondary_accent=$(tput setaf 12)

DOWNLOAD_FOLDER=$1
if [[ ! "$DOWNLOAD_FOLDER" ]]; then
  SCRIPT=$(basename "$0")
  printf "\n**Please provide the folder we're downloading your backup files into. The folder must exist and be empty.\n"
  printf "\nExample: ${SCRIPT} /path/to/folder\n\n"
  exit 1
fi

if [[ ! -d "$DOWNLOAD_FOLDER" ]]; then
  printf "\n**The folder ${DOWNLOAD_FOLDER} does not exist. Please create.\n\n"
  exit 1
fi

if [ "$(ls -A $DOWNLOAD_FOLDER)" ]; then
  printf "\n**The folder ${DOWNLOAD_FOLDER} is not empty.\n\n"
  exit 1
fi

ENV_FILE=$(dirname $0)/.env
if [ ! -f "${ENV_FILE}" ]; then
	printf "\n\n** Please create an env file with the required environment variables at '${ENV_FILE}'."
	exit 1
fi
# Export env variables
export $(cat $ENV_FILE | sed 's/#.*//g' | xargs)

if [[ ! "$BORG_S3_BACKUP_BUCKET" ]]; then
  printf "\n\n**Please provide with BORG_S3_BACKUP_BUCKET on the environment\n"
  exit 1
fi

if [[ ! "$BORG_S3_BACKUP_AWS_PROFILE" ]]; then
  printf "\n\n**Please provide with BORG_S3_BACKUP_AWS_PROFILE on the environment (awscli profile)\n"
  exit 1
fi

DOWNLOAD_FOLDER_AVAILABLE=$(df -B1 ${DOWNLOAD_FOLDER} | tail -1 | awk '{print $4}')

printf "${bold}Computing bucket size...${normal}\n\n"

BUCKET_URI="s3://${BORG_S3_BACKUP_BUCKET}"
BUCKET_SIZE=`aws s3 ls --profile=${BORG_S3_BACKUP_AWS_PROFILE} --summarize --recursive ${BUCKET_URI} | tail -1 | awk '{print \$3}'`
DOWNLOAD_COMMAND="aws s3 sync ${BUCKET_URI} ${DOWNLOAD_FOLDER} --profile=${BORG_S3_BACKUP_AWS_PROFILE}"

BUCKET_SIZE_GB=`numfmt --to iec --format "%8.4f" ${BUCKET_SIZE}`
DOWNLOAD_FOLDER_AVAILABLE_GB=`numfmt --to iec --format "%8.4f" ${DOWNLOAD_FOLDER_AVAILABLE}`

echo "${bold}Bucket size:${normal} ${accent}${BUCKET_SIZE_GB}${normal}"
echo "${bold}Available space at ${secondary_accent}${DOWNLOAD_FOLDER}:${normal} ${accent}${DOWNLOAD_FOLDER_AVAILABLE_GB}${normal}"

if (( $BUCKET_SIZE > $DOWNLOAD_FOLDER_AVAILABLE )); then
  printf "\n**There is not enough space to download your backup at ${secondary_accent}${DOWNLOAD_FOLDER}${normal}\n"
  exit 1
fi

printf "\n${bold}Starting download: ${secondary_accent}${BUCKET_URI} ${accent}--> ${secondary_accent}${DOWNLOAD_FOLDER}${normal}\n\n"

$DOWNLOAD_COMMAND

printf "\n\n${bold}Backup download success.\n\n"