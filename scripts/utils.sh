#!/bin/bash

function print() {
	GREEN='\033[0;32m'
  NC='\033[0m'
  echo
	echo -e "${GREEN}${1}${NC}"
}

function wait_for() {
  local type=$1
  local name=$2

  kubectl -n ${NAMESPACE} wait $type $name --for jsonpath='{.status.type}'=Deployed --timeout=3m
  kubectl -n ${NAMESPACE} rollout status deploy $name
}

function apply_template() {
  local template=$1
  cat ${template} | envsubst | kubectl -n ${NAMESPACE} apply -f -
}