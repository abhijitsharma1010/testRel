#!/bin/bash

# Read output.txt and store Probe ID, Query, SERVER1, SERVER2, SERVER3 in an associative array
declare -A probe_data
while IFS=, read -r probe_id query server1 server2 server3; do
    probe_id=$(echo "$probe_id" | awk -F': ' '{print $2}')
    query=$(echo "$query" | awk -F': ' '{print $2}')
    server1=$(echo "$server1" | awk -F': ' '{print $2}')
    server2=$(echo "$server2" | awk -F': ' '{print $2}')
    server3=$(echo "$server3" | awk -F': ' '{print $2}')
    probe_data["$probe_id"]="$query,$server1,$server2,$server3"
done < <(grep 'Probe ID:' output.txt)

# Process output1.txt and replace 'DNS query' with the corresponding Query value
while IFS= read -r line; do
    probe_id=$(echo "$line" | awk '{print $1}')
    if [[ -n "${probe_data[$probe_id]}" ]]; then
        # Extract Query, SERVER1, SERVER2, SERVER3 from the associative array
        IFS=, read -r query server1 server2 server3 <<< "${probe_data[$probe_id]}"
        # Replace 'DNS query' with the Query value
        updated_line=$(echo "$line" | sed "s/DNS query/$query/")
        # Append SERVER1, SERVER2, SERVER3 to the end of the line
        echo "$updated_line,$server1,$server2,$server3" >> newoutput
    else
        # If no matching Probe ID, keep the line as is
        echo "$line" >> newoutput
    fi
done < output1.txt

echo "New file 'newoutput' has been created with the updated data."
