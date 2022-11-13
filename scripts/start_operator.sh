#!/bin/bash

# Create the namespace, ignoring an error if it previously was created.
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${namespace}
EOF

kubectl -n ${namespace} apply -k kustomization/operator
kubectl -n ${namespace} rollout status deploy fabric-operator