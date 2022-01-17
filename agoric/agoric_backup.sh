#!/bin/bash

# What to backup.
backup_files="/root/.agoric/data"

# Where to backup to.
dest="/mnt/backup-server/agoric"

# Create archive filename.
day=$(date +%A)
archive_file="agoric-$day.tgz"

echo "Stoping Agoric service"
systemctl stop agoricd.service

rm -rf $dest
mkdir -p $dest

# Print start status message.
echo "Backing up $backup_files to $dest/$archive_file"
date
echo

# Backup the files using tar.
tar czfP $dest/$archive_file $backup_files
echo "tar czfP $dest/$archive_file $backup_files"

# Print end status message.
echo
echo "Backup finished"
date

# Long listing of files in $dest to check file sizes.
ls -lh $dest

echo "Starting Agoric service"
systemctl start agoricd.service
