#!/bin/bash

sudo ip netns exec ns-hw1 ping -c 3 10.20.20.2
sudo ip netns exec ns-hw2 ping -c 3 10.20.20.1

sudo ip netns exec ns-hw1 iperf3 -s -D

sudo ip netns exec ns-hw2 iperf3 -c 10.20.20.1 -u -b 10G -l 64 -t 60
