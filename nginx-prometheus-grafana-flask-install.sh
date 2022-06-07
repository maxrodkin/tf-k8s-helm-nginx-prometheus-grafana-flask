#!/bin/bash
helm upgrade --install ingress-nginx ingress-nginx   --repo https://kubernetes.github.io/ingress-nginx   --namespace ingress-nginx --create-namespace
helm upgrade ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --set controller.metrics.enabled=true --set-string controller.podAnnotations."prometheus\.io/scrape"="true" --set-string controller.podAnnotations."prometheus\.io/port"="10254"

kubectl apply --kustomize github.com/kubernetes/ingress-nginx/deploy/prometheus/
kubectl apply --kustomize github.com/kubernetes/ingress-nginx/deploy/grafana/

sudo docker pull calinrus/hit-counter
sudo docker pull redis:alpine

kubectl run redis-lb --image=redis:alpine --port=6379

redis_ip=$(kubectl get po -o wide|grep redis-lb|awk '{ print $6}'|tr -d " \t\n\r")
echo $redis_ip
sed -r "s/redis_ip/$redis_ip/" flask.yaml | kubectl apply -f -

