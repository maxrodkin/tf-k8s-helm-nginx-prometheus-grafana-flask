#!/bin/bash -v
export KUBECONFIG=/etc/kubernetes/admin.conf
#ingress controller
helm upgrade --install ingress-nginx ingress-nginx   --repo https://kubernetes.github.io/ingress-nginx   --namespace ingress-nginx --create-namespace
#prometheus
kubectl apply --kustomize github.com/maxrodkin/ingress-nginx/deploy/prometheus/

public_hostname=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname|tr -d " \t\n\r") && echo $public_hostname

#vault
./vault-install.sh

#grafana
sed -r "s/;domain = localhost/domain = $public_hostname/" grafana.ini > grafana.ini.updated
sed -ri "s/;root_url/root_url/" grafana.ini.updated 
#"root_url = %(protocol)s://%(domain)s:%(http_port)s/"
sed -ri "s/;serve_from_sub_path = false/serve_from_sub_path = true/" grafana.ini.updated 
kubectl delete configmap grafana.ini -n ingress-nginx > /dev/null \
&& kubectl create configmap grafana.ini -n ingress-nginx --from-file=./grafana.ini.updated 
sleep 15
&& kubectl apply --kustomize github.com/maxrodkin/ingress-nginx/deploy/grafana/ 

#ingress
kubectl apply -f nginx_ingress-prometheus-grafana-flask.yaml

#grafana admin pass
sleep 15
grafana_pod_name=$(kubectl get pods -o=name -n ingress-nginx| grep grafana)
echo $grafana_pod_name
kubectl describe $grafana_pod_name -n ingress-nginx
kubectl get $grafana_pod_name -n ingress-nginx
#because of :
#https://stackoverflow.com/questions/60826194/kubectl-exec-fails-with-the-error-unable-to-use-a-tty-input-is-not-a-terminal
#have to remove -t flag:
#kubectl exec $grafana_pod_name -it  -n ingress-nginx -- grafana-cli admin reset-admin-password P@ssw0rd_1
eval "kubectl exec $grafana_pod_name -i  -n ingress-nginx -- grafana-cli admin reset-admin-password P@ssw0rd_1"
