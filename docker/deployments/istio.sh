#!/bin/sh

helm install istio istio/base -n istio
kubectl label namespace microservices istio-injection=enabled
