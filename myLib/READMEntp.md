<div align="center">

<img src="ntplogo.png" width="220">

# 🕒 NIC NTP SERVICE

**National Informatics Centre — Network Time Protocol Infrastructure**

`OS: Rocky Linux 10` &nbsp;|&nbsp; `Status: 🟢 Operational` &nbsp;|&nbsp; `License: NIC © 2026`

Public-facing NTP endpoints: **`time.nic.in`** · **`samay1.nic.in`** · **`samay2.nic.in`** · **`samay1.nkn.in`** · **`samay2.nkn.in`**

</div>

---

## 📑 Table of Contents

- [🖥️ NTP Nodes](#️-ntp-nodes)
- [📋 NTP Logging Node](#-ntp-logging-node)
- [📚 Documentation](#-documentation)
- [⚖️ License & Copyright](#️-license-and-copyright)

---

## 🖥️ NTP Nodes

Ten NTP nodes deployed in pairs (primary/secondary) across five geographic clusters for redundancy and load distribution.

| # | Cluster | VM Name | IP 1 (Internal) | IP 2 (Public) | Hostname | OS |
|:---:|:---|:---|:---|:---|:---|:---:|
| 01 | 🟦 PDNS-SP | `NTP-VM` | `100.70.17.41` | `45.249.236.100` | `samay1-sp` | Rocky 10 |
| 02 | 🟦 PDNS-SP | `NTP-VM-2` | `100.70.17.42` | `45.249.237.100` | `samay2-sp` | Rocky 10 |
| 03 | 🟩 PDNS-CGO | `NTP-CGO-VM-1` | `100.70.41.41` | `45.249.126.101` | `samay1-cgo` | Rocky 10 |
| 04 | 🟩 PDNS-CGO | `NTP-CGO-VM-2` | `100.70.41.42` | `45.249.126.102` | `samay2-cgo` | Rocky 10 |
| 05 | 🟨 PDNS-CH | `NTP-CH-VM-1` | `100.70.44.41` | `45.249.124.101` | `samay1-ch` | Rocky 10 |
| 06 | 🟨 PDNS-CH | `NTP-CH-VM-2` | `100.70.44.42` | `45.249.124.102` | `samay2-ch` | Rocky 10 |
| 07 | 🟧 PDNS-KOL | `NTP-VM-1` | `100.70.31.41` | `121.46.98.100` | `samay1-kol` | Rocky 10 |
| 08 | 🟧 PDNS-KOL | `NTP-VM-2` | `100.70.31.42` | `121.46.98.101` | `samay2-kol` | Rocky 10 |
| 09 | 🟥 PDNS-MUM | `NTP-MUM-VM-1` | `100.70.27.41` | `121.46.96.101` | `samay1-mum` | Rocky 10 |
| 10 | 🟥 PDNS-MUM | `NTP-MUM-VM-2` | `100.70.27.42` | `121.46.96.102` | `samay2-mum` | Rocky 10 |

<details>
<summary>📍 Clusters at a glance</summary>
<br>

| Cluster | Nodes | Region |
|:---|:---:|:---|
| PDNS-SP | 2 | SP |
| PDNS-CGO | 2 | CGO |
| PDNS-CH | 2 | CH |
| PDNS-KOL | 2 | Kolkata |
| PDNS-MUM | 2 | Mumbai |

</details>

---

## 📋 NTP Logging Node

Centralized syslog node for aggregating NTP service logs.

| # | Cluster | VM Name | IP 1 | IP 2 | Hostname | OS |
|:---:|:---|:---|:---|:---|:---|:---:|
| 01 | 🟧 PDNS-KOL | `NTP-SysLog` | `100.70.31.35` | — | `ntp-syslog` | Rocky 10.1 |

---

## 📚 Documentation

| Guide | Description |
|:---|:---|
| 📖 [How to Configure NTP](docs//configure-ntp.md) | Step-by-step NTP configuration instructions |

---

## ⚖️ License and Copyright

<div align="center">

**Copyright © 2026 National Informatics Centre**

*All rights reserved.*

</div>
