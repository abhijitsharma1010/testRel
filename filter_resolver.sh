#!/bin/bash

input_file="resolver_sourceip_mapping.txt"
output_file="filtered_resolvers.txt"

# Filter out lines with private IP addresses in the resolver field
cat "$input_file" | grep -v -E "resolver: (10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.|127\.|::1|fe80:|fd)" > "$output_file"

echo "Filtering complete. Result saved to $output_file"
