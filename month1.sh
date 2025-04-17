#!/bin/bash

# Script to aggregate public IP counts from IP analysis files for a specific month
# Author: Claude
# Date: April 17, 2025

# Directory containing the IP analysis files
# Default is current directory, but you can change this if needed
INPUT_DIR="."

# Prompt the user to enter the month
echo "Please enter the month for which to calculate IP counts (1-12):"
read MONTH_NUMBER

# Validate the month input
if ! [[ "$MONTH_NUMBER" =~ ^[1-9]$|^1[0-2]$ ]]; then
    echo "Error: Please enter a valid month number (1-12)"
    exit 1
fi

# Format the month number with leading zero if necessary
MONTH_FORMATTED=$(printf "%02d" "$MONTH_NUMBER")

# Output file for aggregated results
OUTPUT_FILE="aggregated_public_ips_month_${MONTH_FORMATTED}.txt"

# Temporary file for processing
TEMP_FILE=$(mktemp)

echo "Aggregating public IP counts for month $MONTH_FORMATTED..."
echo "IP Count Aggregation Report for Month $MONTH_FORMATTED" > "$OUTPUT_FILE"
echo "Generated on $(date)" >> "$OUTPUT_FILE"
echo "======================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Process each ip_analysis file in the directory for the specified month
FILE_COUNT=0
for file in "$INPUT_DIR"/ip_analysis_*-${MONTH_FORMATTED}-*.txt; do
    if [ -f "$file" ]; then
        echo "Processing $file..."
        
        # Extract the section between "PUBLIC IPv4 ADDRESSES" and the next section
        sed -n '/PUBLIC IPv4 ADDRESSES/,/PRIVATE IPv4 ADDRESSES/p' "$file" | 
        # Skip the header lines
        grep -v "PUBLIC IPv4 ADDRESSES" | grep -v "PRIVATE IPv4 ADDRESSES" |
        # Extract just the count and IP address, removing leading whitespace
        sed 's/^[[:space:]]*//' |
        # Skip empty lines
        grep -v "^$" >> "$TEMP_FILE"
        
        ((FILE_COUNT++))
    fi
done

if [ $FILE_COUNT -eq 0 ]; then
    echo "No files found for month $MONTH_FORMATTED"
    rm "$TEMP_FILE"
    rm "$OUTPUT_FILE"
    exit 1
fi

# Sort and sum the counts for each IP
echo "PUBLIC IPv4 ADDRESSES (Total Count | Address):" >> "$OUTPUT_FILE"
awk '
    {
        # Extract count and IP address
        count = $1;
        ip = $2;
        
        # Add count to the total for this IP
        ips[ip] += count;
    }
    END {
        # Create an array to store IP and count pairs for sorting
        for (ip in ips) {
            pairs[++i] = sprintf("%8d %s", ips[ip], ip);
        }
        
        # Sort in descending order by count
        for (i = 1; i <= length(pairs); i++) {
            for (j = i + 1; j <= length(pairs); j++) {
                if (substr(pairs[i], 1, 8) + 0 < substr(pairs[j], 1, 8) + 0) {
                    temp = pairs[i];
                    pairs[i] = pairs[j];
                    pairs[j] = temp;
                }
            }
        }
        
        # Print the sorted results
        for (i = 1; i <= length(pairs); i++) {
            print pairs[i];
        }
    }
' "$TEMP_FILE" >> "$OUTPUT_FILE"

# Clean up
rm "$TEMP_FILE"

echo "Aggregation complete. Processed $FILE_COUNT files for month $MONTH_FORMATTED."
echo "Results saved to $OUTPUT_FILE"
