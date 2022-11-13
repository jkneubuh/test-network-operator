# test-network-operator

Create a cloud-native [test-network](https://github.com/hyperledger/fabric-samples/tree/main/test-network) on [KIND](https://kind.sigs.k8s.io) with the [Hyperledger Fabric Operator](https://github.com/hyperledger-labs/fabric-operator)  

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

Check k8s with [k9s](https://k9scli.io/topics/install/):  
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