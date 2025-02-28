#!/bin/bash

# Set the date for yesterday
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)

# Output file for measurement IDs
OUTPUT_FILE="measurement_ids.txt"

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Use RIPE Atlas CLI to search for DNS measurements with the specific description
ripe-atlas measure-search --type dns --description "prok.clean-internet.in" --start-time "$YESTERDAY" | \
jq -r '.[].id' >> "$OUTPUT_FILE"

# Check if any measurements were found
if [ -s "$OUTPUT_FILE" ]; then
    echo "Measurement IDs have been saved to $OUTPUT_FILE"
else
    echo "No measurements found for the given criteria."
fi
