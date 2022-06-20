#!/bin/bash
sudo apt install -y jq

#kubectl apply -f data-vault.yaml
sed -r "s/name: data-vault/name: data-vault-0/" data-vault.yaml | kubectl apply -f -
sed -r "s/name: data-vault/name: data-vault-1/" data-vault.yaml | kubectl apply -f -
sed -r "s/name: data-vault/name: data-vault-2/" data-vault.yaml | kubectl apply -f -

kubectl create namespace vault
helm repo add hashicorp https://helm.releases.hashicorp.com && helm repo update
helm install vault hashicorp/vault -n vault  --values helm-vault-raft-values.yml
#saddly no way to decrease pvc demand
#kubectl patch pvc data-vault-0 -n vault -p '{"spec":{"resources":{"requests":{"storage":"1Gi"}}}}'
#saddly no way to edit pot except his image
#kubectl patch po vault-0 -n vault -p '{"spec":{"affinity":{"podAntiAffinity": null}}}'
kubectl exec vault-0 -n vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json) && echo "$VAULT_UNSEAL_KEY"
kubectl exec vault-0 -n vault -- vault operator unseal $VAULT_UNSEAL_KEY
jq -r ".root_token" cluster-keys.json
#kubectl exec --stdin=true --tty=true vault-0 -n vault -- sh
#vault login
#vault secrets enable -path=secret/ kv
#vault kv put secret/grafana username="admin" password="P@ssw0rd_1"
#vault kv get secret/grafana
#exit

# ubuntu@ip-10-203-47-235:~/tf-k8s-helm-nginx-prometheus-grafana-flask$ VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json)
# ubuntu@ip-10-203-47-235:~/tf-k8s-helm-nginx-prometheus-grafana-flask$ kubectl exec vault-0 -n vault -- vault operator unseal $VAULT_UNSEAL_KEY
# Key             Value
# ---             -----
# Seal Type       shamir
# Initialized     true
# Sealed          false
# Total Shares    1
# Threshold       1
# Version         1.10.3
# Storage Type    file
# Cluster Name    vault-cluster-4a302f5b
# Cluster ID      ac3247e7-300a-6f19-8f10-6250c03fe8b0
# HA Enabled      false
# ubuntu@ip-10-203-47-235:~/tf-k8s-helm-nginx-prometheus-grafana-flask$ jq -r ".root_token" cluster-keys.json
# hvs.DfuBkAX6M6Iz0VT6OgEEmirv
# ubuntu@ip-10-203-47-235:~/tf-k8s-helm-nginx-prometheus-grafana-flask$ echo $VAULT_UNSEAL_KEY
# bA/c7xYf8o9d+63aCkHlnCBvsqH8ssclfXT8Grzn4Kg=
# ubuntu@ip-10-203-47-235:~/tf-k8s-helm-nginx-prometheus-grafana-flask$ kubectl exec --stdin=true --tty=true vault-0 -n vault -- sh
# / $ vault login
# Token (will be hidden):
# Success! You are now authenticated. The token information displayed below
# is already stored in the token helper. You do NOT need to run "vault login"
# again. Future Vault requests will automatically use this token.

# Key                  Value
# ---                  -----
# token                hvs.DfuBkAX6M6Iz0VT6OgEEmirv
# token_accessor       n4s2e3hGqITk55fsT5thlYDo
# token_duration       ∞
# token_renewable      false
# token_policies       ["root"]
# identity_policies    []
# policies             ["root"]

