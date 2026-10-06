#!/bin/bash

# Ask the user for the source directory.
echo "Enter source directory:"
read source

# Stop if the source directory does not exist.
if [[ ! -d "$source" ]]; then
    echo "Source directory does not exist." >&2
    exit 1
fi

# Create a timestamped backup directory.
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
backup_dir="backup_$timestamp"
mkdir -p "$backup_dir"

echo "Backup directory created: $backup_dir"
echo "Copying .txt files..."

# Copy all .txt files and count how many were backed up.
cp "$source"/*.txt "$backup_dir" 2>/dev/null
count=$(find "$backup_dir" -maxdepth 1 -type f -name "*.txt" | wc -l)

echo "Backup complete! Files backed up: $count"
