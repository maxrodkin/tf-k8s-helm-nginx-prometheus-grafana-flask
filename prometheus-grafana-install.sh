#!/bin/bash
#ingress controller
helm upgrade --install ingress-nginx ingress-nginx   --repo https://kubernetes.github.io/ingress-nginx   --namespace ingress-nginx --create-namespace
#prometheus
kubectl apply --kustomize github.com/maxrodkin/ingress-nginx/deploy/prometheus/

public_hostname=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname|tr -d " \t\n\r") && echo $public_hostname

#grafana
sed -r "s/;domain = localhost/domain = $public_hostname/" grafana.ini > grafana.ini.updated
sed -ri "s/;root_url/root_url/" grafana.ini.updated 
sed -ri "s/;serve_from_sub_path = false/serve_from_sub_path = true/" grafana.ini.updated 
kubectl delete configmap grafana.ini -n ingress-nginx > /dev/null
kubectl create configmap grafana.ini -n ingress-nginx --from-file=./grafana.ini.updated
kubectl apply --kustomize github.com/maxrodkin/ingress-nginx/deploy/grafana/ 

#ingress
kubectl apply -f nginx_ingress-prometheus-grafana-flask.yaml

#grafana admin pass
kubectl exec -it $( kubectl get pods -o=name -n ingress-nginx| grep grafana) -n ingress-nginx -- grafana-cli admin reset-admin-password P@ssw0rd_1
