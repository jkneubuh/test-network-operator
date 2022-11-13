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

cluster_name        := env_var_or_default("TEST_NETWORK_CLUSTER_NAME",      "kind")
namespace           := env_var_or_default("TEST_NETWORK_NAMESPACE",         "test-network")
operator_image      := env_var_or_default("TEST_NETWORK_OPERATOR_IMAGE",    "ghcr.io/hyperledger-labs/fabric-operator:latest-amd64")

# Start a local KIND cluster with nginx, localhost:5000 registry, and *.localho.st alias in kube DNS
kind: unkind
    scripts/kind_with_nginx.sh {{cluster_name}}

# Shut down the KIND cluster
unkind:
    #!/bin/bash
    kind delete cluster --name {{cluster_name}}

    if docker inspect kind-registry &>/dev/null; then
        echo "Stopping container registry"
        docker kill kind-registry
        docker rm kind-registry
    fi


###############################################################################
# Test Network
###############################################################################

# Launch the operator in the target namespace
operator:
    scripts/start_operator.sh

# Bring up the test network
network-up: operator network-cas network-nodes

# Shut down the test network
network-down:
    #!/bin/bash
    kubectl -n {{ namespace }} delete ibpca --all
    kubectl -n {{ namespace }} delete ibppeer --all
    kubectl -n {{ namespace }} delete ibporderer --all

# Bring up the org CAs
network-cas:
    scripts/start_cas.sh

# Bring up the network peer and orderer nodes
network-nodes:
    scripts/start_network.sh
