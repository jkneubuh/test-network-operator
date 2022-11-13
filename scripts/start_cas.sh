#!/bin/bash

function wait_for() {
  local type=$1
  local name=$2

  kubectl -n $NS wait $type $name --for jsonpath='{.status.type}'=Deployed --timeout=3m
  kubectl -n $NS rollout status deploy $name
}

kubectl -n $NS apply -k kustomization/cas
sleep 5

wait_for ibpca org0-ca
wait_for ibpca org1-ca
wait_for ibpca org2-ca

## load CA TLS certificates into the env, for substitution into the peer and orderer CRDs
#export ORG0_CA_CERT=$(kubectl -n $NS get cm/org0-ca-connection-profile -o json | jq -r .binaryData.\"profile.json\" | base64 -d | jq -r .tls.cert)
#export ORG1_CA_CERT=$(kubectl -n $NS get cm/org1-ca-connection-profile -o json | jq -r .binaryData.\"profile.json\" | base64 -d | jq -r .tls.cert)
#export ORG2_CA_CERT=$(kubectl -n $NS get cm/org2-ca-connection-profile -o json | jq -r .binaryData.\"profile.json\" | base64 -d | jq -r .tls.cert)

#  enroll_bootstrap_rcaadmin org0 rcaadmin rcaadminpw
#  enroll_bootstrap_rcaadmin org1 rcaadmin rcaadminpw
#  enroll_bootstrap_rcaadmin org2 rcaadmin rcaadminpw


