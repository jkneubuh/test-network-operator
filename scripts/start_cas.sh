#!/bin/bash

function wait_for() {
  local type=$1
  local name=$2

  kubectl -n ${namespace} wait $type $name --for jsonpath='{.status.type}'=Deployed --timeout=3m
  kubectl -n ${namespace} rollout status deploy $name
}

kubectl -n ${namespace} apply -k kustomization/cas
sleep 10

wait_for ibpca org0-ca
wait_for ibpca org1-ca
wait_for ibpca org2-ca
