# test-network-operator
Creates a HL Fabric network using fabric-operator

## TL/DR

```shell
just check 

just kind 
```

```shell
just network-up
```

```shell
export TEST_NETWORK_CHANNEL_NAME=mychannel

just create-channel

just install-chaincode 
```

## Teardown

```shell
just network-down
```

or 

```shell
just unkind
```