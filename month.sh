#!/bin/bash

# Script to aggregate public IP counts from IP analysis files
# Author: Claude
# Date: April 17, 2025

# Directory containing the IP analysis files
# Default is current directory, but you can change this if needed
INPUT_DIR="."

# Output file for aggregated results
OUTPUT_FILE="aggregated_public_ips.txt"

# Temporary file for processing
TEMP_FILE=$(mktemp)

echo "Aggregating public IP counts from analysis files..."
echo "IP Count Aggregation Report" > "$OUTPUT_FILE"
echo "Generated on $(date)" >> "$OUTPUT_FILE"
echo "======================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Process each ip_analysis file in the directory
for file in "$INPUT_DIR"/ip_analysis_*.txt; do
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
    fi
done

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

echo "Aggregation complete. Results saved to $OUTPUT_FILE"
