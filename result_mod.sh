#!/bin/bash

# Define the input file
input_file="/script_output.txt"
output_file="output.txt"

# Initialize an empty output file
> "$output_file"

# Read the input file line by line
while IFS= read -r line; do
    # Check if the line contains "Probe #"
    if [[ $line =~ Probe\ \#([0-9]+) ]]; then
        # Extract the Probe ID
        probe_id="${BASH_REMATCH[1]}"
        
        # Read the next lines to find the DNS query
        while IFS= read -r next_line; do
            # Check if the line contains "QUESTION SECTION"
            if [[ $next_line == *"QUESTION SECTION:"* ]]; then
                # Read the next line to get the actual query
                read -r query_line
                # Extract the query
                query=$(echo "$query_line" | awk '{print $2}')
                
                # Write the formatted output to the output file
                echo "Probe ID: $probe_id, Query: $query" >> "$output_file"
                # Write the probe ID line to the output file
                echo "$line" >> "$output_file"
                break
            fi
        done
    else
        # Write the line to the output file if it's not a probe ID
        echo "$line" >> "$output_file"
    fi
done < "$input_file"

# Display the output file
cat "$output_file"
