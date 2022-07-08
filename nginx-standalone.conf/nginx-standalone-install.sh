#!/bin/bash -v
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl delete configmap nginx-standalone-nginx.conf -n ingress-nginx > /dev/null
kubectl delete configmap nginx-standalone-default.conf -n ingress-nginx > /dev/null
kubectl create configmap nginx-standalone-nginx.conf -n ingress-nginx --from-file=./nginx.conf
kubectl create configmap nginx-standalone-default.conf -n ingress-nginx --from-file=./default.conf

sleep 15

kubectl delete -f ./nginx-standalone.yaml 
kubectl apply -f ./nginx-standalone.yaml 
