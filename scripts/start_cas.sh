#!/bin/bash

function wait_for() {
  local type=$1
  local name=$2

  kubectl -n ${namespace} wait $type $name --for jsonpath='{.status.type}'=Deployed --timeout=3m
  kubectl -n ${namespace} rollout status deploy $name
}

kubectl -n ${namespace} apply -k kustomization/cas
sleep 5

wait_for ibpca org0-ca
wait_for ibpca org1-ca
wait_for ibpca org2-ca

#  enroll_bootstrap_rcaadmin org0 rcaadmin rcaadminpw
#  enroll_bootstrap_rcaadmin org1 rcaadmin rcaadminpw
#  enroll_bootstrap_rcaadmin org2 rcaadmin rcaadminpw


