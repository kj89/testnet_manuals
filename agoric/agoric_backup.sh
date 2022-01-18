#!/bin/bash

# Latest block
latest_block=$(ag0 status 2>&1 | jq .SyncInfo.latest_block_height)

# What to backup.
backup_files="/root/.agoric/data"

# Where to backup to.
dest="/mnt/backup-server/agoric"

# Create archive filename.
archive_file="agoric-$(date +"%d_%m_%Y").tgz"

echo
echo "============================"
echo "Block height: $latest_block"
echo "============================"

echo "Stoping Agoric service"
systemctl stop agoricd.service

rm -rf $dest
mkdir -p $dest

# Print start status message.
echo "Backing up $backup_files to $dest/$archive_file"
date
echo

# Backup the files using tar.
echo "Command: tar czfP $dest/$archive_file $backup_files"
tar czfP $dest/$archive_file $backup_files

# Print end status message.
echo
echo "Backup finished"
date

# Long listing of files in $dest to check file sizes.
ls -lh $dest

echo "Starting Agoric service"
systemctl start agoricd.service
echo "--------------------END--------------------------"
