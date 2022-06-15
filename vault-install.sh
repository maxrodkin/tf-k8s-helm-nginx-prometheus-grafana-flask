#!/bin/bash
#kubectl apply -f data-vault.yaml
sed -r "s/name: data-vault/name: data-vault-0/" data-vault.yaml | kubectl apply -f -
sed -r "s/name: data-vault/name: data-vault-1/" data-vault.yaml | kubectl apply -f -
sed -r "s/name: data-vault/name: data-vault-2/" data-vault.yaml | kubectl apply -f -

kubectl create namespace vault
helm repo add hashicorp https://helm.releases.hashicorp.com
#saddly no way to decrease pvc demand
#kubectl patch pvc data-vault-0 -n vault -p '{"spec":{"resources":{"requests":{"storage":"1Gi"}}}}'