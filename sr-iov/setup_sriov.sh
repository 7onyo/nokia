#!/bin/bash

INTERFACE="ens7f0"

if [ ! -f "/sys/class/net/$INTERFACE/device/sriov_totalvfs" ]; then
    echo "Error: SR-IOV not supported or not enabled for $INTERFACE"
    exit 1
fi

echo "Total VFs supported:"
cat /sys/class/net/$INTERFACE/device/sriov_totalvfs

if ! sudo sh -c "echo 2 > /sys/class/net/$INTERFACE/device/sriov_numvfs"; then
    echo "Error: Failed to generate Virtual Functions."
    exit 1
fi

if ! sudo ip link show | grep -q "${INTERFACE}v0"; then
    echo "Error: Virtual function ${INTERFACE}v0 not found."
    exit 1
fi

if ! sudo ip netns add ns-hw1 || ! sudo ip netns add ns-hw2; then
    echo "Error: Failed to create test namespaces."
    exit 1
fi

if ! sudo ip link set "${INTERFACE}v0" netns ns-hw1 || ! sudo ip link set "${INTERFACE}v1" netns ns-hw2; then
    echo "Error: Failed to move VFs to namespaces."
    exit 1
fi

if ! sudo ip netns exec ns-hw1 ip addr add 10.20.20.1/24 dev "${INTERFACE}v0" || \
   ! sudo ip netns exec ns-hw1 ip link set "${INTERFACE}v0" up || \
   ! sudo ip netns exec ns-hw1 ip link set lo up; then
    echo "Error: Failed to configure ns-hw1."
    exit 1
fi

if ! sudo ip netns exec ns-hw2 ip addr add 10.20.20.2/24 dev "${INTERFACE}v1" || \
   ! sudo ip netns exec ns-hw2 ip link set "${INTERFACE}v1" up || \
   ! sudo ip netns exec ns-hw2 ip link set lo up; then
    echo "Error: Failed to configure ns-hw2."
    exit 1
fi

echo "SR-IOV Setup completed successfully!"
