#!/bin/bash
helm upgrade --install ingress-nginx ingress-nginx   --repo https://kubernetes.github.io/ingress-nginx   --namespace ingress-nginx --create-namespace
#kubectl apply --kustomize github.com/kubernetes/ingress-nginx/deploy/prometheus/
kubectl apply --kustomize github.com/maxrodkin/ingress-nginx/deploy/prometheus/
#kubectl apply --kustomize github.com/kubernetes/ingress-nginx/deploy/grafana/
kubectl apply --kustomize github.com/maxrodkin/ingress-nginx/deploy/grafana/
kubectl apply -f nginx_ingress-prometheus-grafana-flask.yaml
#and find the ingress ip:
#$ kubectl get svc -n ingress-nginx |grep ingress-nginx-controller
#ingress-nginx-controller             LoadBalancer   10.108.205.167   <pending>     80:32191/TCP,443:30735/TCP   117m
#curl http://10.108.205.167/health
#curl http://10.108.205.167/grafana
#curl http://10.108.205.167:32191/app
