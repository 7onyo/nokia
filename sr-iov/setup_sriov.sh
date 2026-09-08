#!/bin/bash

sudo sh -c 'echo 2 > /sys/class/net/ens7f0/device/sriov_numvfs'

sudo ip link show | grep ens7f0

sudo ip netns add ns-hw1
sudo ip netns add ns-hw2

sudo ip link set ens7f0v0 netns ns-hw1
sudo ip link set ens7f0v1 netns ns-hw2

sudo ip netns exec ns-hw1 ip addr add 10.20.20.1/24 dev ens7f0v0
sudo ip netns exec ns-hw1 ip link set ens7f0v0 up
sudo ip netns exec ns-hw1 ip link set lo up

sudo ip netns exec ns-hw2 ip addr add 10.20.20.2/24 dev ens7f0v1
sudo ip netns exec ns-hw2 ip link set ens7f0v1 up
sudo ip netns exec ns-hw2 ip link set lo up
