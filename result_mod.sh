#!/bin/bash

# Input file
input_file="script_output.txt"

# Output file
output_file="output.txt"

# Clear the output file if it exists
> "$output_file"

# Read the input file line by line
while IFS= read -r line; do
    # Check if the line contains a Probe ID
    if [[ $line =~ ^Probe\ \#([0-9]+) ]]; then
        probe_id=${BASH_REMATCH[1]}
        # Initialize query variable
        query=""
        # Read the next lines to find the DNS query
        while IFS= read -r next_line; do
            if [[ $next_line =~ ^\ *;\ QUESTION\ SECTION: ]]; then
                # Extract the query from the next line
                if IFS= read -r query_line; then
                    if [[ $query_line =~ ^\ *;([^;]+) ]]; then
                        # Extract the query and remove the '. IN A' part
                        query=$(echo "${BASH_REMATCH[1]}" | sed 's/\.\s*IN\s*A\s*$//g' | xargs)
                        break
                    fi
                fi
            fi
        done < <(tail -n +$(($(grep -n "$line" "$input_file" | cut -d: -f1) + 1) "$input_file")
        # Write the Probe ID and Query to the output file
        echo "Probe ID: $probe_id, Query: $query" >> "$output_file"
    fi
    # Write the original line to the output file
    echo "$line" >> "$output_file"
done < "$input_file"

echo "Output written to $output_file"
