#!/bin/bash

# Simple calculator that takes two numbers and runs the four basic arithmetic operations.

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
