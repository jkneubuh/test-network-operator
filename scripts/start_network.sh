#!/bin/bash

function wait_for() {
  local type=$1
  local name=$2

  kubectl -n $NS wait $type $name --for jsonpath='{.status.type}'=Deployed --timeout=3m
  kubectl -n $NS rollout status deploy $name
}

# load CA TLS certificates into the env, for substitution into the peer and orderer CRDs
export ORG0_CA_CERT=$(kubectl -n $NS get cm/org0-ca-connection-profile -o json | jq -r .binaryData.\"profile.json\" | base64 -d | jq -r .tls.cert)
export ORG1_CA_CERT=$(kubectl -n $NS get cm/org1-ca-connection-profile -o json | jq -r .binaryData.\"profile.json\" | base64 -d | jq -r .tls.cert)
export ORG2_CA_CERT=$(kubectl -n $NS get cm/org2-ca-connection-profile -o json | jq -r .binaryData.\"profile.json\" | base64 -d | jq -r .tls.cert)

# Apply the peer and orderer CRDs, substituting the CA certs.
kubectl kustomize kustomization/network | envsubst | kubectl -n $NS apply -f -

sleep 5

wait_for ibppeer org1-peer1
wait_for ibppeer org1-peer2
wait_for ibppeer org2-peer1
wait_for ibppeer org2-peer2

wait_for ibporderer org0-orderersnode1
wait_for ibporderer org0-orderersnode2
wait_for ibporderer org0-orderersnode3