#!/bin/bash -v
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl create ns ingress-nginx
sudo docker pull maxi4/hit-counter:prometheus_metrics
sudo docker pull redis:alpine
sleep 10
#kubectl run redis-lb --image=redis:alpine --port=6379 --namespace=ingress-nginx
#sleep 10

#redis_ip=$(kubectl get po --namespace=ingress-nginx -o wide|grep redis-lb|awk '{ print $6}'|tr -d " \t\n\r") && echo $redis_ip
#sed -r "s/redis_ip/$redis_ip/" flask.yaml | kubectl apply -f -

 kubectl apply -f flask-redis.yaml

