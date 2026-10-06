#!/bin/bash

# Ask the user which file they want to check.
echo "Enter filename to check:"
read file

# Stop if the file does not exist.
if [[ ! -f "$file" ]]; then
    echo "File $file does not exist." >&2
    exit 1
fi

echo "File $file exists."

# Check each permission separately.
if [[ -r "$file" ]]; then
    echo "File is readable"
else
    echo "File is not readable"
fi

if [[ -w "$file" ]]; then
    echo "File is writable"
else
    echo "File is not writable"
fi

if [[ -x "$file" ]]; then
    echo "File is executable"
else
    echo "File is not executable"
fi
