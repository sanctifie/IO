#!/usr/bin/env bash
# Projet 15 — cluster EKS, OIDC, AWS Load Balancer Controller, pilote EBS CSI, Robot Shop, Ingress.
set -euo pipefail
export CLUSTER="${CLUSTER:-io-robotshop}" REGION="${REGION:-eu-west-3}"
cd "$(dirname "$0")"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "== 1. Cluster =="
eksctl create cluster --name "$CLUSTER" --region "$REGION" --nodegroup-name workers \
  --node-type t3.medium --nodes 2 --nodes-min 1 --nodes-max 3 --managed

echo "== 2. Fournisseur OIDC =="
eksctl utils associate-iam-oidc-provider --cluster "$CLUSTER" --region "$REGION" --approve

echo "== 3. IRSA pour l'AWS Load Balancer Controller =="
curl -fsSLo /tmp/iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file:///tmp/iam_policy.json >/dev/null 2>&1 \
  || echo "(politique déjà existante)"
eksctl create iamserviceaccount --cluster "$CLUSTER" --region "$REGION" --namespace kube-system \
  --name aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy" --approve --override-existing-serviceaccounts

echo "== 4. Contrôleur (Helm) =="
VPC_ID=$(aws eks describe-cluster --name "$CLUSTER" --region "$REGION" --query "cluster.resourcesVpcConfig.vpcId" --output text)
helm repo add eks https://aws.github.io/eks-charts >/dev/null && helm repo update eks >/dev/null
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
  --set clusterName="$CLUSTER" --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller \
  --set region="$REGION" --set vpcId="$VPC_ID"
kubectl -n kube-system rollout status deploy/aws-load-balancer-controller --timeout=180s

echo "== 5. Pilote EBS CSI =="
eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster "$CLUSTER" --region "$REGION" \
  --role-name AmazonEKS_EBS_CSI_DriverRole --role-only \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve
eksctl create addon --name aws-ebs-csi-driver --cluster "$CLUSTER" --region "$REGION" \
  --service-account-role-arn "arn:aws:iam::$ACCOUNT_ID:role/AmazonEKS_EBS_CSI_DriverRole" --force
kubectl get storageclass gp2 >/dev/null 2>&1 || kubectl apply -f storageclass-gp2.yaml

echo "== 6. Robot Shop =="
[ -d RobotShop-Project ] || git clone --depth 1 https://github.com/uniquesreedhar/RobotShop-Project.git
kubectl create namespace robot-shop --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install robot-shop RobotShop-Project/EKS/helm -n robot-shop

echo "== 7. Ingress =="
kubectl apply -f ingress.yaml
until A=$(kubectl -n robot-shop get ingress robot-shop -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') && [ -n "$A" ]; do sleep 10; done
echo "Robot Shop : http://$A"
