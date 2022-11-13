# test-network-operator
Creates a test network on Kubernetes with the Hyperledger [fabric-operator](https://github.com/hyperledger-labs/fabric-operator)  

## TL/DR

Ready?
```shell
just check 
```

Set:
```shell
just kind 
```

Go!
```shell
just network-up
```

`w00t w00t`: [k9s](https://k9scli.io/topics/install/)
```shell
k9s -n test-network
```

TODO: 
```shell
# just create-channel
# just install-chaincode ... 
# just run-gateway-client ... 
```



## Teardown

```shell
just unkind
```