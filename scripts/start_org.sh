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

#
# KISS:  Don't invest in this script.  Just do:
#
ORG=$1


#
# Start the org CAs
#
TEMPLATE=network/$ORG/cas/$ORG-ca.yaml
CA=$(basename $TEMPLATE .yaml)

print "Starting $ORG ibpca $CA"
apply_template $TEMPLATE
sleep 2 # todo fixme - wait for k8s to construct the resource
wait_for ibpca $CA

# Retrieve the org CA certificate for the bootstrap enrollment of peers/orderers
export CA_CERT=$(kubectl -n ${NAMESPACE} get cm/${ORG}-ca-connection-profile -o json | jq -r .binaryData.\"profile.json\" | base64 -d | jq -r .tls.cert)


#
# Launch peers and orderers
#
for TEMPLATE in $(ls network/${ORG}/orderers)
do
  ORDERER=$(basename $TEMPLATE .yaml)

  print "Starting $ORG ibporderer $ORDERER"
  apply_template network/$ORG/orderers/$TEMPLATE
done

for TEMPLATE in $(ls network/$ORG/peers)
do
  PEER=$(basename $TEMPLATE .yaml)

  print "Starting $ORG ibppeer $PEER"
  apply_template network/$ORG/peers/$TEMPLATE
done

sleep 5

#
# Wait for peers and orderers to come online
#
for TEMPLATE in $(ls network/${ORG}/orderers)
do
  ORDERER=$(basename $TEMPLATE .yaml)

  # todo: fix this...
  wait_for ibporderer ${ORDERER}node1
  wait_for ibporderer ${ORDERER}node2
  wait_for ibporderer ${ORDERER}node3
done

for TEMPLATE in $(ls network/$ORG/peers)
do
  PEER=$(basename $TEMPLATE .yaml)
  wait_for ibppeer $PEER
done

