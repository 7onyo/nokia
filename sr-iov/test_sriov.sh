#!/bin/bash

if ! sudo ip netns exec ns-hw1 ping -c 3 10.20.20.2; then
    echo "Error: Ping from ns-hw1 to ns-hw2 failed!"
    exit 1
fi

if ! sudo ip netns exec ns-hw2 ping -c 3 10.20.20.1; then
    echo "Error: Ping from ns-hw2 to ns-hw1 failed!"
    exit 1
fi

echo "Ping test passed. Starting iperf3 test."

if ! sudo ip netns exec ns-hw1 iperf3 -s -D; then
    echo "Error: Failed to start iperf3 server in ns-hw1."
    exit 1
fi

if ! sudo ip netns exec ns-hw2 iperf3 -c 10.20.20.1 -u -b 10G -l 64 -t 60; then
    echo "Error: iperf3 client test failed."
    exit 1
fi

echo "SR-IOV Test completed successfully!"
