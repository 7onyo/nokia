#!/bin/bash

sudo ip netns exec ns-sw1 ping -c 3 10.30.30.2
sudo ip netns exec ns-sw2 ping -c 3 10.30.30.1

sudo ip netns exec ns-sw1 iperf3 -s -D

sudo ip netns exec ns-sw2 iperf3 -c 10.30.30.1 -u -b 10G -l 64 -t 60
