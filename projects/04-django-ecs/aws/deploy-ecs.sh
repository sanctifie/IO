#!/usr/bin/env bash
# Projet 04 — crée (ou met à jour) le cluster, la task definition et le service Fargate dans le VPC par défaut.
# Usage : ./deploy-ecs.sh v1   (l'image doit avoir été poussée avec push-ecr.sh)
set -euo pipefail
TAG="${1:-v1}"
REGION="${AWS_REGION:-eu-west-3}"
CLUSTER=io-django-cluster
SERVICE=django-service
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IMAGE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/hello-world-django-app:$TAG"
export AWS_DEFAULT_REGION="$REGION"

# 1. Rôle d'exécution des tâches (tirer l'image, écrire les logs)
if ! aws iam get-role --role-name ecsTaskExecutionRole >/dev/null 2>&1; then
  aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document \
    '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ecs-tasks.amazonaws.com"},"Action":"sts:AssumeRole"}]}' >/dev/null
  aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
fi

# 2. Cluster
aws ecs create-cluster --cluster-name "$CLUSTER" >/dev/null

# 3. Task definition (nouvelle révision à chaque exécution)
sed -e "s#__IMAGE__#$IMAGE#" -e "s#__ACCOUNT__#$ACCOUNT_ID#" -e "s#__REGION__#$REGION#" "$(dirname "$0")/taskdef.json" > /tmp/taskdef.json
aws ecs register-task-definition --cli-input-json file:///tmp/taskdef.json >/dev/null

# 4. Réseau : VPC par défaut, Security Group port 8000 depuis mon IP
VPC=$(aws ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text)
SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="$VPC" --query 'Subnets[].SubnetId' --output text | tr '\t' ',')
SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=django-sg Name=vpc-id,Values="$VPC" --query 'SecurityGroups[0].GroupId' --output text)
if [ "$SG" = "None" ]; then
  SG=$(aws ec2 create-security-group --group-name django-sg --description "Projet 04" --vpc-id "$VPC" --query GroupId --output text)
  aws ec2 authorize-security-group-ingress --group-id "$SG" --protocol tcp --port 8000 --cidr "$(curl -s https://checkip.amazonaws.com)/32" >/dev/null
fi

# 5. Service : création, ou mise à jour (rolling update) s'il existe
if [ "$(aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" --query 'services[0].status' --output text)" = "ACTIVE" ]; then
  aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --task-definition django-task --force-new-deployment >/dev/null
else
  aws ecs create-service --cluster "$CLUSTER" --service-name "$SERVICE" --task-definition django-task \
    --desired-count 1 --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],securityGroups=[$SG],assignPublicIp=ENABLED}" >/dev/null
fi
echo "Attente de la stabilisation du service..."
aws ecs wait services-stable --cluster "$CLUSTER" --services "$SERVICE"

TASK=$(aws ecs list-tasks --cluster "$CLUSTER" --service-name "$SERVICE" --query 'taskArns[0]' --output text)
ENI=$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK" --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text)
IP=$(aws ec2 describe-network-interfaces --network-interface-ids "$ENI" --query 'NetworkInterfaces[0].Association.PublicIp' --output text)
echo "Application : http://$IP:8000/hello/"
