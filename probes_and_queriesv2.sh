#!/bin/bash

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$dir"

epoch_time=$(date +%s)

PROBES_IDS=$(paste -sd, list.of.indian.ipv4.probes)

# Define the output file for probe IDs and queries
probes_queries_file="probes_and_queries.txt"

# Define the output file for script output
script_output_file="script_output.log"

# Clear the output files if they exist
> "$probes_queries_file"
> "$script_output_file"

# Redirect all script output (stdout and stderr) to the script output file
exec >> "$script_output_file" 2>&1

while IFS= read -r PROBE_ID; do
    QUERY_ARG="${PROBE_ID}_${epoch_time}.prok.clean-internet.in"

    # Save the probe ID and query to the probes and queries file
    echo "Probe ID: $PROBE_ID, Query: $QUERY_ARG" >> "$probes_queries_file"

    # Run the RIPE Atlas command
    /root/.local/bin/ripe-atlas measure dns \
        --query-argument="$QUERY_ARG" \
        --query-type=A \
        --from-probes="$PROBE_ID" \
        --description="DNS query for ${QUERY_ARG}" \
        --timeout 10000
done < list.of.indian.ipv4.probes
