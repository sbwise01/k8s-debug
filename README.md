# k8s-debug
A docker image used to deploy a debug container image to k8s

## Building
`docker build -t sbwise/k8s-debug:1.0.0 .`

## Publish
`docker push sbwise/k8s-debug:1.0.0`

## Run on k8s cluster
`kubectl run -it --rm=true --restart=Never --image sbwise/k8s-debug:1.0.0 --namespace default "$(whoami)-interactive"`
