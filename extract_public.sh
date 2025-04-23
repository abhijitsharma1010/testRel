#!/bin/bash

# Check if input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"
output_file="resolver_sourceip_mapping.txt"
debug_file="debug_output.txt"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found."
    exit 1
fi

# Clear output files
> "$output_file"
> "$debug_file"

echo "Starting to process file: $input_file" >> "$debug_file"

# Function to check if an IP is a public IP (not a private/local IP)
is_public_ip() {
    local ip="$1"
    
    # Skip empty values, NA, or non-IP entries
    if [[ -z "$ip" || "$ip" == "NA" ]]; then
        return 1
    fi
    
    # Check for private IP ranges
    if [[ "$ip" =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.|fe80:|fd|::1) ]]; then
        return 1
    fi
    
    # Check for loopback addresses
    if [[ "$ip" =~ ^127\. || "$ip" == "::1" ]]; then
        return 1
    fi
    
    # Check if it looks like an IP address (IPv4 or IPv6)
    if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ || "$ip" =~ ^[0-9a-fA-F:]+$ ]]; then
        return 0
    fi
    
    return 1
}

# First line of the file is likely the header
header_line=$(head -n 1 "$input_file")
echo "Header line: $header_line" >> "$debug_file"

# Skip header line and process data
awk -F ';;' 'NR > 1 {
    resolver_1 = $11;
    resolver_2 = $12;
    resolver_3 = $13;
    sourceip_1 = $14;
    sourceip_2 = $15;
    sourceip_3 = $16;
    
    # Remove ** prefix from sourceip values
    gsub(/\*\*/, "", sourceip_1);
    gsub(/\*\*/, "", sourceip_2);
    gsub(/\*\*/, "", sourceip_3);
    
    # Output all resolver-sourceip pairs for debugging
    print "Line " NR ":" > "'$debug_file'";
    print "  resolver_1: " resolver_1 > "'$debug_file'";
    print "  resolver_2: " resolver_2 > "'$debug_file'";
    print "  resolver_3: " resolver_3 > "'$debug_file'";
    print "  sourceip_1: " sourceip_1 > "'$debug_file'";
    print "  sourceip_2: " sourceip_2 > "'$debug_file'";
    print "  sourceip_3: " sourceip_3 > "'$debug_file'";
}' "$input_file"

# Process the file again with IP filtering
awk -F ';;' 'NR > 1 {
    resolver_1 = $11;
    resolver_2 = $12;
    resolver_3 = $13;
    sourceip_1 = $14;
    sourceip_2 = $15;
    sourceip_3 = $16;
    
    # Remove ** prefix from sourceip values
    gsub(/\*\*/, "", sourceip_1);
    gsub(/\*\*/, "", sourceip_2);
    gsub(/\*\*/, "", sourceip_3);
    
    # Output only public IP addresses
    if (resolver_1 != "NA" && resolver_1 != "" && sourceip_1 != "NA" && sourceip_1 != "") {
        cmd = "bash -c '\''source \"'$BASH_SOURCE'\"; is_public_ip \"" sourceip_1 "\" && echo true || echo false'\''"
        cmd | getline is_public
        close(cmd)
        if (is_public == "true") {
            print "resolver: " resolver_1 " -> sourceip: " sourceip_1 > "'$output_file'"
        }
    }
    if (resolver_2 != "NA" && resolver_2 != "" && sourceip_2 != "NA" && sourceip_2 != "") {
        cmd = "bash -c '\''source \"'$BASH_SOURCE'\"; is_public_ip \"" sourceip_2 "\" && echo true || echo false'\''"
        cmd | getline is_public
        close(cmd)
        if (is_public == "true") {
            print "resolver: " resolver_2 " -> sourceip: " sourceip_2 > "'$output_file'"
        }
    }
    if (resolver_3 != "NA" && resolver_3 != "" && sourceip_3 != "NA" && sourceip_3 != "") {
        cmd = "bash -c '\''source \"'$BASH_SOURCE'\"; is_public_ip \"" sourceip_3 "\" && echo true || echo false'\''"
        cmd | getline is_public
        close(cmd)
        if (is_public == "true") {
            print "resolver: " resolver_3 " -> sourceip: " sourceip_3 > "'$output_file'"
        }
    }
}' "$input_file"

# Count lines in output file
output_lines=$(wc -l < "$output_file")
echo "Output file has $output_lines lines" >> "$debug_file"

# If output is empty, try a different approach
if [ "$output_lines" -eq 0 ]; then
    echo "First approach yielded no results. Trying alternative approach..." >> "$debug_file"
    
    # Process all lines and try to find Resolver and Sourceip fields at different positions
    while IFS= read -r line; do
        echo "Processing line: ${line:0:60}..." >> "$debug_file"
        
        IFS=";;" read -ra fields <<< "$line"
        
        # Debug array size
        echo "  Number of fields: ${#fields[@]}" >> "$debug_file"
        
        # Try different positions for resolvers and sourceips
        for i in {0..20}; do
            if [ $i -lt ${#fields[@]} ]; then
                echo "  Field $i: ${fields[$i]}" >> "$debug_file"
            fi
        done
        
        # Look for specific patterns in fields
        for i in "${!fields[@]}"; do
            if [[ "${fields[$i]}" == "8.8.8.8" || "${fields[$i]}" == "1.1.1.1" || "${fields[$i]}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo "  Potential resolver IP at position $i: ${fields[$i]}" >> "$debug_file"
                
                # Check if the next field might be a source IP
                next=$((i + 3))  # Skip ahead to potential sourceip
                if [ $next -lt ${#fields[@]} ]; then
                    sourceip="${fields[$next]}"
                    sourceip="${sourceip/\*\*/}"
                    if is_public_ip "$sourceip"; then
                        echo "resolver: ${fields[$i]} -> sourceip: $sourceip" >> "$output_file"
                    fi
                fi
            fi
        done
        
    done < "$input_file"
fi

# Sort and remove duplicates
sort -u "$output_file" -o "$output_file"

# Final check
output_lines=$(wc -l < "$output_file")
if [ "$output_lines" -eq 0 ]; then
    echo "Error: No resolver-sourceip mappings found. Check debug_output.txt for details."
else
    echo "Processing complete. Found $output_lines resolver-sourceip mappings."
    echo "Results saved to $output_file"
fi
