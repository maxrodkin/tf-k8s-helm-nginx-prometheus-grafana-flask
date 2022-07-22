#!/bin/bash -v
grafana_admin_password=$1
export KUBECONFIG=/etc/kubernetes/admin.conf
sudo apt install -y jq > /dev/null

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
sleep 15

#because of "Unable to use a TTY - input is not a terminal or the right kind of file"
#remove -t switch
#kubectl exec vault-0 -it -n vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
kubectl exec vault-0 -i -n vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json) && echo "VAULT_UNSEAL_KEY=$VAULT_UNSEAL_KEY"
kubectl exec vault-0 -it -n vault -- vault operator unseal $VAULT_UNSEAL_KEY
root_token=$(jq -r ".root_token" cluster-keys.json) && echo "root_token=$root_token"
kubectl exec --stdin=true --tty=true vault-0 -n vault -- sh -c "echo $root_token | vault login - && \
vault secrets enable -path=secret/ kv && \
vault kv put secret/grafana username=\"admin\" password=\"$grafana_admin_password\" && \
vault kv get secret/grafana && \
exit"
