#!/bin/bash

# Input and output file paths
input_file="input.txt"
output_file="output.txt"

# Clear the output file if it exists
> "$output_file"

# Initialize variables
probe_id=""
query=""
server_count=0
servers=()

# Read the input file line by line
while IFS= read -r line; do
    # Check if the line contains "Probe ID"
    if [[ $line == *"Probe ID:"* ]]; then
        # If there's already a Probe ID and servers collected, write them to the output file
        if [[ -n "$probe_id" && $server_count -gt 0 ]]; then
            output="Probe ID: $probe_id, Query: $query"
            for ((i = 0; i < server_count; i++)); do
                output+=", SERVER$((i+1)): ${servers[i]}"
            done
            echo "$output" >> "$output_file"
        fi

        # Reset variables for the new Probe ID
        probe_id=$(echo "$line" | awk '{print $3}' | tr -d ',')
        query=""
        server_count=0
        servers=()
    fi

    # Check if the line contains "Query:"
    if [[ $line == *"Query:"* ]]; then
        query=$(echo "$line" | awk '{print $2}')
    fi

    # Check if the line contains "SERVER:"
    if [[ $line == *"SERVER:"* ]]; then
        # Extract the IP address inside the parentheses
        server_ip=$(echo "$line" | grep -oP '(?<=\()[^)]+')
        servers+=("$server_ip")
        server_count=$((server_count + 1))
    fi
done < "$input_file"

# Write the last collected Probe ID and servers to the output file
if [[ -n "$probe_id" && $server_count -gt 0 ]]; then
    output="Probe ID: $probe_id, Query: $query"
    for ((i = 0; i < server_count; i++)); do
        output+=", SERVER$((i+1)): ${servers[i]}"
    done
    echo "$output" >> "$output_file"
fi

echo "Data extraction complete. Results saved in $output_file."
