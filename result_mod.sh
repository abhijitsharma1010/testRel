#!/bin/bash

# Input file
input_file="script_output.txt"

# Output file
output_file="output_mod.txt"

# Read the input file line by line
while IFS= read -r line; do
    # Check if the line starts with "Probe #"
    if [[ $line == "Probe #"* ]]; then
        # Extract the probe ID
        probe_id=$(echo "$line" | awk '{print $2}' | tr -d '#')
        
        # Read the next lines to find the DNS query
        while IFS= read -r next_line; do
            # Check if the line contains the DNS query
            if [[ $next_line == *"QUESTION SECTION:"* ]]; then
                # Extract the DNS query
                query=$(echo "$next_line" | awk '{print $1}' | sed 's/;//g')
                
                # Write the Probe ID and Query to the output file
                echo "Probe ID: $probe_id, Query: $query" >> "$output_file"
                break
            fi
        done
    fi
    
    # Write the original line to the output file
    echo "$line" >> "$output_file"
done < "$input_file"

echo "Processing complete. Output saved to $output_file"
