#!/bin/bash

if ! sudo ip netns exec ns-sw1 ping -c 3 10.30.30.2; then
    echo "Error: Ping from ns-sw1 to ns-sw2 failed!"
    exit 1
fi

if ! sudo ip netns exec ns-sw2 ping -c 3 10.30.30.1; then
    echo "Error: Ping from ns-sw2 to ns-sw1 failed!"
    exit 1
fi

echo "Ping test passed. Starting iperf3 test."

if ! sudo ip netns exec ns-sw1 iperf3 -s -D; then
    echo "Error: Failed to start iperf3 server in ns-sw1."
    exit 1
fi

if ! sudo ip netns exec ns-sw2 iperf3 -c 10.30.30.1 -u -b 10G -l 64 -t 60; then
    echo "Error: iperf3 client test failed."
    exit 1
fi

echo "Bridge Test completed successfully!"
