#!/bin/bash

set -e

echo "-------------------------------------------------------"
echo "NODE  : $NODE_ID"
echo "PEERS : $NODE_PEERS"
echo "-------------------------------------------------------"

OPTS=""

python ids.py node-pk $NODE_ID > nodekey.txt
NODE_PK=$(python ids.py node-id $NODE_ID)
echo "ID: $NODE_PK"

NODE_IP=$(host $NODE_ID | awk '/has address/ { print $4 ; exit }')
echo "IP: $NODE_IP"

touch bootnodes.txt
while IFS=',' read -ra PEERS; do
    for name in ${PEERS[@]}; do
      PEER_ID=$(python ids.py node-id $name)
      PEER_HOST="$name"
      PEER_IP=$(host $PEER_HOST | awk '/has address/ { print $4 ; exit }')
      echo "enode://$PEER_ID@${PEER_IP:-127.0.0.1}:30303" >> bootnodes.txt
    done
done <<<  "$NODE_PEERS"

BOOTNODES=$(cat bootnodes.txt)
echo "PEERS:"
echo $BOOTNODES

NODEADDR=$(python ids.py addr $NODE_ID)

OPTS="$OPTS --db-path /data"
OPTS="$OPTS --chain /opt/parity/ecip1017chain.json"
OPTS="$OPTS --no-discovery"
OPTS="$OPTS --reserved-only"
OPTS="$OPTS --reserved-peers bootnodes.txt"
OPTS="$OPTS --nodekey nodekey.txt"
OPTS="$OPTS --author $NODEADDR"
OPTS="$OPTS --nat extip:0.0.0.0"
OPTS="$OPTS --jsonrpc-hosts all --jsonrpc-interface all --jsonrpc-port 8545"

echo "-------------------------------------------------------"
echo "Run Parity:"
echo "    $OPTS"
echo "-------------------------------------------------------"


/parity/parity $OPTS
