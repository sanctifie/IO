#!/usr/bin/env bash
# Initialise le plan de contrôle et installe le réseau Flannel. À lancer sur le master après install-k8s-node.sh.
set -euo pipefail
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p "$HOME/.kube"
sudo cp -f /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
echo "Commande à exécuter sur chaque worker :"
kubeadm token create --print-join-command
