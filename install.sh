#!/bin/sh
git clone https://github.com/maxrodkin/tf-k8s-helm-nginx-prometheus-grafana-flask.git \
&& cd tf-k8s-helm-nginx-prometheus-grafana-flask
./docker_install.sh  
./get_helm.sh      
./k8s_install.sh                 
./flask-install.sh   
./prometheus-grafana-install.sh

cd nginx-standalone.conf
./nginx-standalone-install.sh