#!/bin/bash
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
kubeadm version
nc 127.0.0.1 6443
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

ip a|grep inet|grep 192.168.0

sudo cp -f config.toml /etc/containerd/config.toml
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube && \
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml && \
kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml
kubectl taint nodes --all node-role.kubernetes.io/control-plane- node-role.kubernetes.io/master-
