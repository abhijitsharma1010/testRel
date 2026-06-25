# 🕒 NTP Configuration Guide

> A quick reference for syncing system clocks to **`time.nic.in`** across Windows, Linux, macOS, and Cisco IOS.

---

## 📑 Table of Contents

- [Windows](#-1-microsoft-windows)
- [Linux (Ubuntu / Debian / RHEL / Rocky)](#-2-linux-ubuntudebianrhelrockyos)
- [macOS](#-3-macos)
- [Cisco IOS](#-4-cisco-ios-network-devices)
- [Firewall Requirements](#-firewall-requirements)

---

## 🪟 1. Microsoft Windows

**Via GUI**

| Step | Action |
|------|--------|
| 1 | Open **Control Panel** → **Clock and Region** → **Date and Time** |
| 2 | Go to the **Internet Time** tab → click **Change settings** |
| 3 | Check **"Synchronize with an Internet time server"** |
| 4 | Enter `time.nic.in` in the server box → click **Update now** |

---

## 🐧 2. Linux (Ubuntu/Debian/RHEL/RockyOS)

> Most modern distributions use **`systemd-timesyncd`** out of the box.

**Step 1 — Edit the config file**

```bash
sudo nano /etc/systemd/timesyncd.conf
```

**Step 2 — Update the `[Time]` section**

```ini
[Time]
NTP=time.nic.in
FallbackNTP=pool.ntp.org
```

**Step 3 — Restart the service**

```bash
sudo systemctl restart systemd-timesyncd
```

<details>
<summary>✅ Verify sync status</summary>

```bash
timedatectl show-timesync --all
timedatectl timesync-status
```

</details>

---

## 🍎 3. macOS

> macOS uses the `sntp` / `timed` daemon, configurable via Terminal.

**Set the time server:**

```bash
sudo systemsetup -setnetworktimeserver time.nic.in
```

**Verify the setting:**

```bash
sntp -S time.nic.in
```

---

## 🌐 4. Cisco IOS (Network Devices)

> For routers and switches — enter global configuration mode first.

```cisco
configure terminal
ntp server time.nic.in
end
write memory
```

---

## 🔒 Firewall Requirements

> [!IMPORTANT]
> Ensure **UDP Port 123** is open for **both inbound and outbound** traffic to allow NTP synchronization to function correctly.

| Protocol | Port | Direction |
|----------|------|-----------|
| UDP | 123 | Inbound & Outbound |

---

<sub>📌 Reference time server used throughout this guide: `time.nic.in` (NIC, India)</sub>
