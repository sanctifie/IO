#!/usr/bin/env bash
# Prépare un nœud Kubernetes (master OU worker) : containerd + kubeadm/kubelet/kubectl. Bible : annexe A.6
# Usage : K8S=v1.34 ./install-k8s-node.sh   (mettre la version mineure stable actuelle)
set -euo pipefail
K8S="${K8S:-v1.34}"
sudo swapoff -a && sudo sed -i '/ swap / s/^/#/' /etc/fstab
printf 'overlay\nbr_netfilter\n' | sudo tee /etc/modules-load.d/k8s.conf > /dev/null
sudo modprobe overlay && sudo modprobe br_netfilter
cat <<SYSCTL | sudo tee /etc/sysctl.d/k8s.conf > /dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
SYSCTL
sudo sysctl --system > /dev/null
sudo apt-get update && sudo apt-get install -y containerd apt-transport-https ca-certificates curl gpg
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd && sudo systemctl enable containerd
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S}/deb/Release.key" | sudo gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S}/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
echo "Nœud prêt. Master : ./k8s-init-master.sh ; worker : commande 'kubeadm join' affichée par le master."
