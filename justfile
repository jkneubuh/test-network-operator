#
# Copyright contributors to the Hyperledgendary Full Stack Asset Transfer project
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
# 	  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Main justfile to run all the development scripts
# To install 'just' see https://github.com/casey/just#installation


###############################################################################
#
###############################################################################


# Ensure all properties are exported as shell env-vars
set export

# set the current directory, and the location of the test dats
CWDIR := justfile_directory()

_default:
  @just -f {{justfile()}} --list

# Run the check script to validate third party dependencies
check:
  ${CWDIR}/scripts/check.sh


###############################################################################
# KIND / k8s
###############################################################################

CLUSTER_NAME        := env_var_or_default("TEST_NETWORK_CLUSTER_NAME",      "kind")
NAMESPACE           := env_var_or_default("TEST_NETWORK_NAMESPACE",         "test-network")
OPERATOR_IMAGE      := env_var_or_default("TEST_NETWORK_OPERATOR_IMAGE",    "ghcr.io/hyperledger-labs/fabric-operator:latest-amd64")
FABRIC_VERSION      := env_var_or_default("TEST_NETWORK_FABRIC_VERSION",    "2.4.7")
FABRIC_CA_VERSION   := env_var_or_default("TEST_NETWORK_FABRIC_CA_VERSION", "1.5.5")

# Start a local KIND cluster with nginx and insecure docker registry
kind: unkind
    scripts/kind_with_nginx.sh {{CLUSTER_NAME}}

# Shut down the KIND cluster
unkind:
    #!/bin/bash
    kind delete cluster --name {{CLUSTER_NAME}}

    if docker inspect kind-registry &>/dev/null; then
        echo "Stopping container registry"
        docker kill kind-registry
        docker rm kind-registry
    fi


###############################################################################
# Test Network
###############################################################################

network-up: operator
    just start org0
    just start org1
    just start org2

start org:
    network/{{ org }}/start.sh

# Shut down the test network
network-down:
    # heavy hammer:
    kubectl delete ns {{ NAMESPACE }}

    # let the operator clean house:
    # kubectl -n {{ NAMESPACE }} delete ibpca --all
    # kubectl -n {{ NAMESPACE }} delete ibppeer --all
    # kubectl -n {{ NAMESPACE }} delete ibporderer --all
    # ...

# Launch the operator in the target namespace
operator:
    scripts/start_operator.sh

