import gzip
import csv

# Step 1: Extract DNS Queries from mainoutput.txt
dns_queries = []
with open('mainoutput.txt', 'r') as main_file:
    reader = csv.reader(main_file, delimiter=';;')
    next(reader)  # Skip header
    for row in reader:
        dns_queries.append(row[1])  # DNS_Query is the second column

# Step 2: Read and Match from queries-20250303.gz
matched_ips = {}
with gzip.open('queries-20250303.gz', 'rt') as queries_file:
    for line in queries_file:
        parts = line.strip().split()
        if len(parts) >= 2:  # Ensure there are at least two parts (query and IP)
            query = parts[0]
            ip = parts[1]
            if query in dns_queries:
                matched_ips[query] = ip

# Step 3: Append the IP Address to mainoutput.txt
output_lines = []
with open('mainoutput.txt', 'r') as main_file:
    reader = csv.reader(main_file, delimiter=';;')
    header = next(reader)
    output_lines.append(';;'.join(header) + ';;Matched_IP\n')  # Add new column header
    for row in reader:
        dns_query = row[1]
        matched_ip = matched_ips.get(dns_query, 'NA')  # Get matched IP or 'NA' if not found
        output_lines.append(';;'.join(row) + ';;' + matched_ip + '\n')

# Write the updated content back to mainoutput.txt
with open('mainoutput.txt', 'w') as main_file:
    main_file.writelines(output_lines)

print("IP addresses have been appended to mainoutput.txt")
