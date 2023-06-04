#!/bin/bash

git clone https://github.com/GoogleCloudPlatform/microservices-demo
cd microservices-demo/
kubectl apply -f ./release/kubernetes-manifests.yaml
