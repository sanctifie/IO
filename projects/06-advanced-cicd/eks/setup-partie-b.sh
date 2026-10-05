#!/usr/bin/env bash
# Projet 06, partie B — cluster EKS, accès de l'agent Jenkins, namespace + secret registre, monitoring.
# Usage : AGENT_ROLE_ARN=arn:aws:iam::<compte>:role/<role-agent> ./setup-partie-b.sh
set -euo pipefail
: "${AGENT_ROLE_ARN:?AGENT_ROLE_ARN manquant (rôle IAM attaché à l’instance agent)}"
cd "$(dirname "$0")"
eksctl create cluster -f cluster.yaml
aws eks create-access-entry --cluster-name io-06 --region eu-west-3 --principal-arn "$AGENT_ROLE_ARN"
aws eks associate-access-policy --cluster-name io-06 --region eu-west-3 --principal-arn "$AGENT_ROLE_ARN" \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy --access-scope type=cluster
kubectl create namespace sample-app --dry-run=client -o yaml | kubectl apply -f -
read -rp "Utilisateur JFrog : " JUSER; read -rsp "Token JFrog : " JTOKEN; echo; read -rp "Hôte JFrog (ex : moi.jfrog.io) : " JHOST
kubectl create secret docker-registry dockercred -n sample-app --docker-server="$JHOST" \
  --docker-username="$JUSER" --docker-password="$JTOKEN" --dry-run=client -o yaml | kubectl apply -f -
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
echo "Sur l'agent : aws eks update-kubeconfig --region eu-west-3 --name io-06 ; puis variable DEPLOY_TO_EKS=true dans Jenkins."
echo "Grafana : kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80"
echo "NETTOYAGE : helm uninstall sample-app -n sample-app ; helm uninstall monitoring -n monitoring ; eksctl delete cluster -f cluster.yaml"
