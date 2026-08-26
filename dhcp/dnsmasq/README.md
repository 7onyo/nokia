# DHCP Server Demo with dnsmasq

Notes on configuring a temporary DHCP server using `dnsmasq` and testing with a Linux client.

## Linux DHCP Server

**Note:** `enp5s0` is used as the example network interface.

### 1. Prepare the Network Interface

Disable the firewall to allow DHCP traffic (ports 67/68):
```bash
sudo ufw disable

```

Prevent NetworkManager from automatically resetting or modifying the IP configuration:

```bash
sudo nmcli dev set enp5s0 managed no

```

Set a custom static IP for the interface:

```bash
sudo ip addr add 192.168.99.1/24 dev enp5s0

```

Ensure the interface is up (often not required, but ensures connectivity):

```bash
sudo ip link set enp5s0 up

```

### 2. Start the DHCP Server

`dnsmasq` is run in foreground/debug mode (`-d`).

**Dynamic IP Range Configuration**

Serves IP addresses between `.10` and `.50` with a 12-hour lease time:

```bash
sudo dnsmasq -d --interface=enp5s0 --bind-interfaces --dhcp-range=192.168.99.10,192.168.99.50,12h

```

---

## Linux Client

Commands for the client machine to test the DHCP server connection.

Disable the firewall to ensure the DHCP offer is received:

```bash
sudo ufw disable

```

Release the current IP lease:

```bash
sudo dhclient -r

```

Request a new IP address (verbose mode to view the transaction details):

```bash
sudo dhclient -v

```

---

## Testing Connectivity

Verify bidirectional communication after the client receives an IP.

**Ping Server from Client**

Targets the static IP configured on the DHCP server:

```bash
ping 192.168.99.1

```

**Ping Client from Server**

Targets the IP assigned to the client:

```bash
#example
ping 192.168.99.10

```