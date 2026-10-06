# Bash Scripting

A record of the four Bash scripting challenges I completed after finishing the Bash module.

The aim was not just to make the scripts run. I wanted the code to stay close to the way I actually think through Bash: understand the command, understand the condition around it, then use the script to automate work I would otherwise do manually in the terminal.

---

## Challenge 1: Basic Arithmetic Calculator

### Brief Description

This script takes two numbers from the user and performs addition, subtraction, multiplication and division.

It checks whether the second number is `0` before division so the invalid operation is handled without affecting the other calculations.

### Final Script

```bash
#!/bin/bash

# Ask the user for two numbers.
echo "Enter first number:"
read number1

echo "Enter second number:"
read number2

# Perform the arithmetic operations.
addition=$((number1 + number2))
subtraction=$((number1 - number2))
multiplication=$((number1 * number2))

echo "Results:"
echo "$number1 + $number2 = $addition"
echo "$number1 - $number2 = $subtraction"
echo "$number1 * $number2 = $multiplication"

# Do not divide by zero.
if (( number2 == 0 )); then
    echo "$number1 / $number2 = Cannot divide by zero"
else
    division=$((number1 / number2))
    echo "$number1 / $number2 = $division"
fi
```

### Learning Notes

- **Interactive input and positional parameters**
  - `read` collects values while the script is running.
  - `$1`, `$2`, `$@` and `$#` relate to arguments supplied when the script is launched.
  - This script uses `read` because the numbers are entered after execution begins.

- **Arithmetic expansion**
  - `$(( ))` tells Bash to evaluate an arithmetic expression.
  - The result can be assigned to a variable and reused later.
  - Inside arithmetic expansion, variable names can be referenced directly.

- **Integer arithmetic**
  - Bash performs integer arithmetic by default.
  - `5 / 2` evaluates to `2`, not `2.5`.
  - Decimal arithmetic needs a different approach or another tool.

- **Conditional handling**
  - Division has a specific invalid case when the divisor is `0`.
  - The condition protects the division operation without stopping the valid addition, subtraction and multiplication results.

### Notes to Keep in Mind

- `read` and `$1` / `$2` both provide values to a script, but they do so at different stages.
- Variables inside `$(( ))` do not need `$` before their names.
- Division by zero should block the division operation, not terminate the whole calculator.

---

## Challenge 2: File Operations

### Brief Description

This script creates a `bash_demo` directory, moves into it, creates `demo.txt`, writes the current date into the file and then displays the file contents.

The full sequence is handled by the script rather than relying on the directory or file being created manually beforehand.

### Final Script

```bash
#!/bin/bash

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
```

### Learning Notes

- **Automating the full workflow**
  - The script owns the whole sequence: `mkdir → cd → touch → > → cat`.
  - A Bash script should not depend on me manually creating the directory or file first if those steps are part of the task.

- **Directory creation and movement**
  - `mkdir -p bash_demo` creates the directory and avoids an unnecessary error if it already exists.
  - `cd bash_demo || exit 1` means the script stops if changing directory fails instead of continuing in the wrong location.

- **Command substitution**
  - `$(date +%Y-%m-%d)` runs `date` and inserts its output into the line written to the file.
  - Command substitution lets the result of one command become part of another command.

- **Redirection**
  - `> demo.txt` sends stdout into the file rather than the terminal.
  - `>` overwrites the target file; `>>` would append instead.

### Notes to Keep in Mind

- Doing `mkdir`, `cd` and `touch` manually in the terminal is Linux practice, but it does not satisfy an automation task if the script is meant to perform those steps.
- `cd bash_demo || exit 1` uses command exit status: if `cd` fails, `exit 1` runs.
- `touch demo.txt` makes the file-creation step explicit even though the later `>` redirection could also create the file.

---

## Challenge 3: File Checker

### Brief Description

This script takes a filename from the user, stops if the file does not exist, then checks whether the file is readable, writable and executable.

The permission checks are kept separate because a file can satisfy more than one of them at the same time.

### Final Script

```bash
#!/bin/bash

# Ask the user which file they want to check.
echo "Enter filename to check:"
read file

# Stop if the file does not exist.
if [[ ! -f "$file" ]]; then
    echo "File $file does not exist." >&2
    exit 1
fi

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
```

### Learning Notes

- **Guard-clause structure**
  - `[[ ! -f "$file" ]]` checks the failure case first.
  - If the file does not exist, the script reports the error and exits.
  - If execution continues after that point, I already know the file exists.

- **File test operators**
  - `-f` checks for a regular file.
  - `-r`, `-w` and `-x` check whether the file is readable, writable and executable by the current user.

- **Independent conditions**
  - Read, write and execute permissions are separate properties.
  - They need separate `if` blocks rather than an `elif` chain because more than one condition can be true.

- **stderr and exit status**
  - `>&2` sends the error message to stderr.
  - `exit 1` ends the script with a non-zero status.
  - They solve two different problems: where the error message goes and whether the script reports success or failure.

### Notes to Keep in Mind

- `"$file"` stays quoted because the variable may contain spaces or characters that should remain part of one filename.
- An `elif` chain would stop checking once the first true permission test is found.
- Error output and process exit status are related, but they are not the same thing.

---

## Challenge 4: Backup Script

### Brief Description

This script takes a source directory, validates that it exists, creates a timestamped backup directory, copies the source `.txt` files into it and reports how many files were actually backed up.

### Final Script

```bash
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
mkdir "$backup_dir" || exit 1

echo "Backup directory created: $backup_dir"
echo "Copying .txt files..."

# Copy all .txt files and count how many were backed up.
cp "$source"/*.txt "$backup_dir" 2>/dev/null
count=$(find "$backup_dir" -maxdepth 1 -type f -name "*.txt" | wc -l)

echo "Files backed up: $count"
```

### Learning Notes

- **Directory validation**
  - `[[ ! -d "$source" ]]` checks the failure case before the backup starts.
  - If the source directory is invalid, the script writes an error to stderr and exits with status `1`.

- **Command substitution and variables**
  - `$(date +%Y-%m-%d_%H-%M-%S)` creates a timestamp that can be stored and reused.
  - The timestamp becomes part of `backup_dir`, giving the backup a time-based directory name.

- **Quoting and globbing**
  - In `"$source"/*.txt`, the directory variable is quoted so its value stays intact.
  - The `*.txt` part remains outside those quotes so Bash can expand the glob and match text files.

- **Pipes and verifying the result**
  - `find "$backup_dir" -maxdepth 1 -type f -name "*.txt" | wc -l` counts files that actually exist inside the completed backup.
  - That is better than counting source files and assuming every copy succeeded.

### Notes to Keep in Mind

- Validate the source before creating or copying anything.
- `mkdir "$backup_dir" || exit 1` stops the script rather than reusing an existing backup directory if the generated name already exists.
- `2>/dev/null` suppresses the expected `cp` error when there are no matching `.txt` files; it should not be used blindly to hide useful errors.
- Count the resulting backup state rather than assuming the intended operation completed successfully.

---

## Why Bash Matters in DevOps

Bash gives me a way to turn Linux commands I already use manually into repeatable workflows.

Commands such as `find`, `grep`, `cp`, `tar`, `ssh`, `chmod` and `cat` solve individual problems. Bash adds the logic around them through variables, conditions, loops, input, exit statuses, redirection and command composition.

That is where it becomes useful in DevOps. Instead of repeating the same sequence manually, I can define the sequence once, validate the conditions around it and run it consistently.

These challenges are small examples, but the same model carries into environment setup, deployment scripts, CI/CD jobs, backups, log processing and operational troubleshooting.
