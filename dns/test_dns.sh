#!/bin/bash

# A simple script to test DNS resolution on the client machines.
# Run this script from client-1 or client-2 after provisioning.

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
SEP=$(printf -- '-%.0s' {1..60})

EXTERNAL_SERVER='nokia.com'

echo -e "\n${CYAN}1. Testing ping to client-1 using FQDN (client-1.demo.internal)${NC}"
echo -e "${GREEN}${SEP}${NC}"
ping -c 3 client-1.demo.internal

echo -e "\n${CYAN}2. Testing ping to client-1 using short name (client-1)${NC}"
echo -e "${GREEN}${SEP}${NC}"
ping -c 3 client-1

echo -e "\n${CYAN}3. Testing ping to client-2 using FQDN (client-2.demo.internal)${NC}"
echo -e "${GREEN}${SEP}${NC}"
ping -c 3 client-2.demo.internal

echo -e "\n${CYAN}4. Testing ping to client-2 using short name (client-2)${NC}"
echo -e "${GREEN}${SEP}${NC}"
ping -c 3 client-2

echo -e "\n${CYAN}5. Querying the DNS server directly (10.0.0.2) for client-1${NC}"
echo -e "${GREEN}${SEP}${NC}"
dig @10.0.0.2 client-1.demo.internal +short

echo -e "\n${CYAN}6. Testing external forward resolution with dig (${EXTERNAL_SERVER})${NC}"
echo -e "${GREEN}${SEP}${NC}"
dig ${EXTERNAL_SERVER} +short

echo -e "\n${CYAN}7. Testing external forward resolution with ping (${EXTERNAL_SERVER})${NC}"
echo -e "${GREEN}${SEP}${NC}"
ping -c 3 ${EXTERNAL_SERVER}

echo -e "\n${GREEN}All tests completed!${NC}\n"
