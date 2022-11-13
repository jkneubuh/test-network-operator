#!/bin/bash

# Create the namespace, ignoring an error if it previously was created.
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${namespace}
EOF

# Substitute just/env variables into the kustomization before applying to k8s
kubectl kustomize kustomization/operator | envsubst | kubectl -n ${namespace} apply -f -

kubectl -n ${namespace} rollout status deploy fabric-operator