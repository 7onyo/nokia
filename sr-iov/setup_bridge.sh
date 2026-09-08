#!/bin/bash

if ! sudo ip link add name br0 type bridge; then
    echo "Error: Failed to create software bridge br0."
    exit 1
fi

if ! sudo ip link set br0 up; then
    echo "Error: Failed to bring up bridge br0."
    exit 1
fi

if ! sudo ip netns add ns-sw1 || ! sudo ip netns add ns-sw2; then
    echo "Error: Failed to create test namespaces."
    exit 1
fi

if ! sudo ip link add veth1 type veth peer name veth1-br || \
   ! sudo ip link add veth2 type veth peer name veth2-br; then
    echo "Error: Failed to create veth pairs."
    exit 1
fi

if ! sudo ip link set veth1-br master br0 up || \
   ! sudo ip link set veth2-br master br0 up; then
    echo "Error: Failed to attach veth to bridge."
    exit 1
fi

if ! sudo ip link set veth1 netns ns-sw1 || \
   ! sudo ip link set veth2 netns ns-sw2; then
    echo "Error: Failed to move veth interfaces to namespaces."
    exit 1
fi

if ! sudo ip netns exec ns-sw1 ip addr add 10.30.30.1/24 dev veth1 || \
   ! sudo ip netns exec ns-sw1 ip link set veth1 up || \
   ! sudo ip netns exec ns-sw1 ip link set lo up; then
    echo "Error: Failed to configure ns-sw1."
    exit 1
fi

if ! sudo ip netns exec ns-sw2 ip addr add 10.30.30.2/24 dev veth2 || \
   ! sudo ip netns exec ns-sw2 ip link set veth2 up || \
   ! sudo ip netns exec ns-sw2 ip link set lo up; then
    echo "Error: Failed to configure ns-sw2."
    exit 1
fi

echo "Bridge Setup completed successfully!"
