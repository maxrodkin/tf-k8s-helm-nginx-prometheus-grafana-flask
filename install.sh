#!/bin/sh
#git clone https://github.com/maxrodkin/tf-k8s-helm-nginx-prometheus-grafana-flask.git \
#&& cd tf-k8s-helm-nginx-prometheus-grafana-flask
grafana_admin_password="P@ssw0rd_1"
./docker_install.sh  
./get_helm.sh      
./k8s_install.sh                 
./flask-install.sh   
./prometheus-grafana-install.sh $grafana_admin_password

cd nginx-standalone.conf
./nginx-standalone-install.sh

cd ..
./vault-install.sh $grafana_admin_password