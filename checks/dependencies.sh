#!/bin/bash

# Define the files
REQUIREMENTS_IN="requirements.in"
REQUIREMENTS_TXT="requirements.txt"

# Flag to track if any line is not found
all_found=true

# Loop through each line in requirements.in
while IFS= read -r line
do
    # Check if the line is in requirements.txt (case-insensitive)
    if grep -Fxiq "$line" "$REQUIREMENTS_TXT"
    then
        echo "Found: $line"
    else
        echo "Not found: $line"
        all_found=false
    fi
done < "$REQUIREMENTS_IN"

# Check the flag and exit accordingly
if [ "$all_found" = false ]; then
    echo "One or more lines were not found in $REQUIREMENTS_TXT."
    exit 1
else
    echo "All lines were found."
    exit 0
fi
