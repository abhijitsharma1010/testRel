#!/bin/bash

input_file="output1.txt"
output_file="unique_servers.txt"

# Extract all server IPs (SERVER1, SERVER2, SERVER3) and count occurrences
awk '{
    for(i=1; i<=NF; i++) {
        if ($i ~ /^SERVER[123]:/) {
            split($i, a, ":")
            ip = a[2]
            if (ip != "") {
                ips[ip]++
            }
        }
    }
} 
END {
    print "Unique Server IPs and their counts:"
    print "-----------------------------------"
    for (ip in ips) {
        printf "%-40s %d\n", ip, ips[ip]
    }
}' "$input_file" | sort -k2,2nr > "$output_file"

echo "Results written to $output_file"
