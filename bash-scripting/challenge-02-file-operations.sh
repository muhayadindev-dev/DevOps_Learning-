#!/bin/bash

# Automates creating a directory and file, writing the date and displaying the result.

# Create the demo directory and move into it.
mkdir -p bash_demo
cd bash_demo || exit 1

# Create demo.txt and write the current date into it.
touch demo.txt
echo "This file was created by a Bash script on $(date +%Y-%m-%d)" > demo.txt

# Display the file contents.
echo "Directory bash_demo created."
echo "File demo.txt created."
echo "File contents:"
cat demo.txt
