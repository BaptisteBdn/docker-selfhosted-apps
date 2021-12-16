# About

<p align="center">
<img src="../_utilities/borg.svg" alt="Borg" title="Borg" />
</p>

BorgBackup is a deduplicating backup program, it supports compression and authenticated encryption.
Borg is a key element for this selfhosted infrastructure as it will back up all your valuable data, the scripts alongside borg provides the following features :

- Local backup of your docker repository
    - docker-compose, env files, etc.
    - **volumes** containing important data for your containers 
- External cloud backup on AWS (S3)
- Backup notifications with [Gotify](../gotify)

The scripts are a modified version of [luispabon/borg-s3-home-backup](https://github.com/luispabon/borg-s3-home-backup).

# Table of Contents

<!-- TOC -->

- [About](#about)
- [Table of Contents](#table-of-contents)
- [File structure](#file-structure)
- [Information](#information)
    - [env](#env)
        - [borg](#borg)
        - [aws](#aws)
        - [Gotify](#gotify)
    - [Backup scripts](#backup-scripts)
- [Usage](#usage)
    - [Requirements](#requirements)
    - [Configuration](#configuration)
    - [Download and extract backups](#download-and-extract-backups)
- [Security](#security)

<!-- /TOC -->

# File structure 

```
.
|-- .env
|-- backup-borg-s3.sh*
|-- download-backup-s3.sh*
`-- excludes.txt
```
- `.env` - a file containing all the environment variables used in backup scripts
- `backup-borg-s3.sh`- a script to back up your data : locally and in the cloud (AWS S3)
- `download-backup-s3.sh`- a script to download your data from the cloud
- `excludes.txt` - an exclude file, default will back up all your docker infrastructure 

Please make sure that all the files and directories are present.

# Information

Borg requires user's specific configuration. 

## .env
Links to the following [.env](.env).

### borg

```
# Directory to back up
DOCKER_DIR=/path/to/docker_directory
```
The directory containing all the configuration of the docker containers, usually the directory you cloned this guide into.


```
# Borg repository
BORG_REPO=/path/to/borg_repository
BORG_PASSPHRASE=borg_passphrase
```
The borg repository where the backups will be located, and the corresponding passphrase used to encrypt the datas.

To create the repository and set your passphrase :

```
borg init --encryption=repokey /path/to/repo
```

> You can use [vaultwarden](../vaultwarden) to store your passphrase securly.

### aws

> Keep in mind that AWS S3 is not free. Currently, with approximatly 50 GB of data it costs me around $1 per month.

```
# AWS configuration
BORG_S3_BACKUP_BUCKET=bucket_name
BORG_S3_BACKUP_AWS_PROFILE=aws_backup_profile
```

AWS provides a lot of services, we are gonna use S3 : Amazon Simple Storage Service (Amazon S3) is an object storage service where you can store and protect any amount of data for virtually any use case.
It is a great, reliable and cheap way to store your already encrypted backups.

In order to use S3, you will need an AWS account. If you do not have one, I suggest following the [AWS startup guide](https://aws.amazon.com/getting-started/guides/setup-environment/), only the first 3 modules are important. 

Within your AWS account, create another user within IAM, if you followed the guide you should already have created one, I recommend creating a unique user for the backup.

Next, create your S3 bucket, keep in mind that the name of the bucket must be unique between all users using S3, you can choose something like `aws-docker-selfhosted-backups-8888`. Please be careful not to put your bucket publicly visible, by default it should not be.

Then, go to IAM, select your backup user and choose `Add permissions` then `Attach existing policies` and then `Create policy`. On the editor, choose JSON and set the following policy for your backup user while changing with the name of the bucket you just created.

`S3-full-access-backup-bucket`
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "arn:aws:s3:::name-of-your-bucket"
        }
    ]
}
```

Once this is done, add it to your user, this will give full access to the bucket you created to your backup user.

Now everything is configured within your AWS account, the last step is to configure the profile on your docker host. This step is explained in the module 3 in the [AWS startup guide](https://aws.amazon.com/getting-started/guides/setup-environment/).

> NOTE: Content inside docker volumes can be sometimes owned by root as they are created by docker, as a result, to avoid conflict I run the backups and AWS upload as root. If you want to do the same, the AWS profile will have to be configured inside root's home.

The AWS configuration is finished, add the bucket name and the name of your aws profile to the `.env` file.

To check that everything is set up correctly, use the following command (as root if you plan to run the backup as root):

```
aws s3 ls --profile=your-profile-name --summarize --recursive s3://name-of-your-bucket
```

The response should be empty, but you should not have any error.

### Gotify

You need to have a selfhosted [gotify](../gotify) available, check the guide if you want to know how to generate a token.

## Backup scripts

The backup script works in 5 steps :

- Stops all running docker container to ensure uncorrupted files
- Create local borg backup 
- Prune old backups
    - Keep the most up to date daily, weekly and monthly backup
- Synchronise the local backup to the AWS bucket (kind of like rsync would do)
- Starts all docker containers
- Notify using Gotify


The download script works in 2 steps :

- Check that you have enough space on your host
- Download the remote encrypted backup


# Usage

## Requirements

Please ensure that the `.env` is correctly configure.

## Configuration

While you want to keep most of the data, you may also want to exclude heavy files from backups (media files, logs, etc.).
Add any **full path** to any directory or file that you want to exclude to `exclude.txt`.

> Default will back up EVERYTHING. I also recommend setting the BACKUP_THRESHOLD value in the `.env` as it will prevent any AWS upload if the backup is larger than the setting.

Now that everything is set up, you can run the backup script.

```
/bin/bash /path/to/backup-borg-s3.sh >> /var/log/backup.log
```

You can also use cron to automate the backup.

```
1 3 * * 1 root /bin/bash /path/to/backup-borg-s3.sh >> /var/log/backup.log
```
This will run the backup script as root every monday at 3.

## Download and extract backups

If you ever need your backup, borg makes it pretty easy.

First, download the backup using the download backup script, you will need the `.env` with only the AWS settings (aws bucket name and AWS profile name).

```
/bin/bash /download-backup-s3.sh /tmp/aws-backup
```

List the backups available (you will need your passphrase).

```
borg list /tmp/aws-backup
```

Then create and move to the folder you want to extract your backup in.

```
mkdir /tmp/extracted-backup && cd /tmp/extracted-backup
```

Finally, extract the backup you need (it will extract in the directory you are located in).

```
borg extract /tmp/aws-backup::backup-2021-12-06T03.01
```


# Security

A few security points : 
- Please be careful not to put your bucket publicly visible, by default it should not be.
- You can store your passphrase in [vaultwarden](../vaultwarden).
- Test your backup recovery process, try to download, extract and run your backup to check if everything runs correctly.
- Check the backup scripts and try to understand them, you will have more trust in your backup, that's the beauty of opensource.


