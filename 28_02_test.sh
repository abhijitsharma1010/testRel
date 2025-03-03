#!/bin/bash

# Static header line
header="Probe ID;;DNS Query;;Probe Ipv4;;ProbeIpv6;;Probe Prefix v4;;Probe Prefix v6;;Probe ASNv4;;Probe Country;;Anchor;;Probe Coordinates;;Resolver1;;Resolver2;;Resolver3"

# Write the header to the newoutput file
echo "$header" > newoutput

# Read output.txt and store Probe ID, Query, SERVER1, SERVER2, SERVER3 in arrays
declare -a probe_ids
declare -a queries
declare -a server1s
declare -a server2s
declare -a server3s

while IFS=, read -r probe_id query server1 server2 server3; do
    probe_id=$(echo "$probe_id" | awk -F': ' '{print $2}')
    query=$(echo "$query" | awk -F': ' '{print $2}')
    server1=$(echo "$server1" | awk -F': ' '{print $2}')
    server2=$(echo "$server2" | awk -F': ' '{print $2}')
    server3=$(echo "$server3" | awk -F': ' '{print $2}')
    probe_ids+=("$probe_id")
    queries+=("$query")
    server1s+=("$server1")
    server2s+=("$server2")
    server3s+=("$server3")
done < <(grep 'Probe ID:' output.txt)

# Process output1.txt and replace 'DNS query' with the corresponding Query value
while IFS= read -r line; do
    probe_id=$(echo "$line" | awk '{print $1}')
    found=0
    for i in "${!probe_ids[@]}"; do
        if [[ "${probe_ids[$i]}" == "$probe_id" ]]; then
            # Extract Query, SERVER1, SERVER2, SERVER3 from the arrays
            query="${queries[$i]}"
            server1="${server1s[$i]}"
            server2="${server2s[$i]}"
            server3="${server3s[$i]}"
            # Replace 'DNS query' with the Query value
            updated_line=$(echo "$line" | sed "s/DNS query/$query/")
            # If $server2 or $server3 is empty, replace it with "NA"
            server2=${server2:-NA}
            server3=${server3:-NA}
            # Append SERVER1, SERVER2, SERVER3 to the end of the line
            echo "$updated_line,$server1,$server2,$server3" >> newoutput
            found=1
        fi
    done
    if [[ $found -eq 0 ]]; then
        # If no matching Probe ID, keep the line as is
        echo "$line" >> newoutput
    fi
done < output1.txt

# Replace occurrences of ";; - ;;" with ";; NA ;;"
sed -i 's/;; - ;;/;; NA ;;/g' newoutput

echo "New file 'newoutput' has been created with the updated data and header."
