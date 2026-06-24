# 1.10.10.10-tests

Daily network measurement logs for public DNS resolvers and ping latency, collected using **RIPE Atlas probes** installed at multiple locations across India. This repo tracks how **1.10.10.10**, **1.1.1.1**, **8.8.8.8**, and **9.9.9.9** perform over time, with raw counts/logs and auto-generated HTML bar-graph visualizations for each day.

## Why

Public DNS resolvers are often marketed on speed and reliability, but real-world performance varies by region and over time. This repo is a long-running, day-by-day measurement log to see how these resolvers actually behave across Indian networks, rather than relying on vendor claims.

## Measurement setup

All measurements are gathered using [RIPE Atlas](https://atlas.ripe.net/) probes deployed across multiple locations in India. RIPE Atlas is a global, community-driven Internet measurement network — using it here means the results reflect real network paths and conditions from distributed vantage points, not just a single host or VM.

## What's being measured

| Resolver     | Provider        |
|--------------|------------------|
| `1.10.10.10` | NIC / DoT (India) |
| `1.1.1.1`    | Cloudflare       |
| `8.8.8.8`    | Google           |
| `9.9.9.9`    | Quad9            |

Two kinds of tests are tracked:

- **DNS** (`/dns`) — DNS query log counts per resolver, captured daily.
- **Ping** (`/ping`) — ICMP ping measurement counts per resolver, captured daily.

## Repo structure

```
.
├── dns/
│   ├── data/                      # Daily raw DNS query counts, one folder per date
│   │   └── DD-MM-YYYY/
│   │       └── dns_measurement_count_DD-MM-YYYY
│   └── html/                      # Daily DNS bar-graph visualizations
│       └── dns_measurement_India_bargraph_YYYY-MM-DD.html
│
└── ping/
    ├── data/                      # Daily raw ping counts, one folder per date
    │   └── DD-MM-YYYY/
    │       └── ping_measurement_India_data_count_DD-MM-YYYY
    └── html/                      # Daily ping bar-graph visualizations
        └── ping_measurement_India_graph_DD-MM-YYYY.html
```

### Data format

Each daily data file is a simple resolver → count text file, e.g.:

```
1.10.10.10  : 12557
1.1.1.1     : 12687
8.8.8.8     : 12716
9.9.9.9     : 12969
```

### HTML graphs

Each `.html` file under `dns/html/` and `ping/html/` is a self-contained, dynamically-scaled bar graph for that day — open it directly in a browser, no server or dependencies required. Bar heights are scaled relative to that day's maximum value, so graphs are easiest to read day-by-day rather than across days.

## How the data is collected

Measurements run on RIPE Atlas probes located across India, with a small set of Bash scripts that:

1. Pull DNS/ping measurement results for each resolver from the RIPE Atlas API for that day.
2. Count/aggregate the results per resolver and write them to `dns/data/<date>/` or `ping/data/<date>/`.
3. Render a per-day HTML bar graph into `dns/html/` or `ping/html/`.

> The collection scripts themselves aren't included in this repo (yet) — this repo currently holds the generated data and graphs.

## Notes

- Dates in `dns/` use `YYYY-MM-DD` for HTML files and `DD-MM-YYYY` for data folders/files.
- Dates in `ping/` consistently use `DD-MM-YYYY`.
- This is an ongoing/ever-growing dataset — new folders and graphs are added daily.

## License

No license specified yet — all rights reserved by default until one is added.
