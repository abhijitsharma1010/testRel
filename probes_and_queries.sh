#!/bin/bash

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$dir"

epoch_time=$(date +%s)

PROBES_IDS=$(paste -sd, list.of.indian.ipv4.probes)

# Define the output file
output_file="probes_and_queries.txt"

# Clear the output file if it exists
> "$output_file"

while IFS= read -r PROBE_ID; do
    QUERY_ARG="${PROBE_ID}_${epoch_time}.prok.clean-internet.in"

    # Save the probe ID and query to the output file
    echo "Probe ID: $PROBE_ID, Query: $QUERY_ARG" >> "$output_file"

    /root/.local/bin/ripe-atlas measure dns \
        --query-argument="$QUERY_ARG" \
        --query-type=A \
        --from-probes="$PROBE_ID" \
        --description="DNS query for ${QUERY_ARG}" \
        --timeout 10000
done < list.of.indian.ipv4.probes
