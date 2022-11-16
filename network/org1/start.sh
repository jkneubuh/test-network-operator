#!/bin/bash

. scripts/utils.sh

# KISS: No scripting.  Just bring up org1 nodes.

#
# CA
#
print "starting org1 CA"

apply_template network/org1/org1-ca.yaml
sleep 2
wait_for ibpca org1-ca

# Retrieve the org CA certificate for the bootstrap enrollment of peers/orderers
export CA_CERT=$(kubectl -n ${NAMESPACE} get cm/org1-ca-connection-profile -o json | jq -r .binaryData.\"profile.json\" | base64 -d | jq -r .tls.cert)



#
# Network nodes
#
print "starting org1 orderers"

print "starting org1 peers"

apply_template network/org1/org1-peer1.yaml
apply_template network/org1/org1-peer2.yaml
sleep 2 

wait_for ibppeer org1-peer1
wait_for ibppeer org1-peer2