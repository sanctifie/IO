#!/usr/bin/env bash
# Projet 23 — prérequis en CLI : ECR, paramètres SSM, rôle d'exécution ECS, première task definition.
# L'ALB, les 2 target groups, le cluster, le service blue/green et le pipeline se créent ensuite
# dans la console (étapes 5 et 6 de la bible).
# Usage : SONAR_TOKEN=... SONAR_URL=http://<IP>:9000 ./setup-prereqs.sh
set -euo pipefail
: "${SONAR_TOKEN:?SONAR_TOKEN manquant}" "${SONAR_URL:?SONAR_URL manquant}"
export AWS_DEFAULT_REGION="${REGION:-eu-west-3}"
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="$ACCOUNT.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
cd "$(dirname "$0")/.."

aws ecr describe-repositories --repository-names swiggy >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name swiggy --image-scanning-configuration scanOnPush=true >/dev/null

aws ssm put-parameter --name /cicd/sonar/sonar-token --type SecureString --value "$SONAR_TOKEN" --overwrite >/dev/null
aws ssm put-parameter --name /cicd/sonar/url         --type String       --value "$SONAR_URL"   --overwrite >/dev/null

# Rôle d'exécution ECS (tirer l'image d'ECR, écrire les logs)
cat > /tmp/ecs-trust.json <<'JSON'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ecs-tasks.amazonaws.com"},"Action":"sts:AssumeRole"}]}
JSON
aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document file:///tmp/ecs-trust.json >/dev/null 2>&1 || true
aws iam attach-role-policy --role-name ecsTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
# awslogs-create-group=true exige aussi logs:CreateLogGroup
aws iam put-role-policy --role-name ecsTaskExecutionRole --policy-name create-log-group --policy-document \
  '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"logs:CreateLogGroup","Resource":"*"}]}'

# Première image (construite localement) et première task definition
sed -i "s/123456789012/$ACCOUNT/" taskdef.json
aws ecr get-login-password | docker login --username AWS --password-stdin "$REGISTRY"
docker build -t "$REGISTRY/swiggy:initial" app
docker push "$REGISTRY/swiggy:initial"
sed "s#<IMAGE1_NAME>#$REGISTRY/swiggy:initial#" taskdef.json > /tmp/taskdef-initial.json
aws ecs register-task-definition --cli-input-json file:///tmp/taskdef-initial.json \
  --query 'taskDefinition.taskDefinitionArn' --output text

cat <<INFO
Politique à ajouter au rôle de service CodeBuild (après sa création) :
  ssm:GetParameters sur arn:aws:ssm:$AWS_DEFAULT_REGION:$ACCOUNT:parameter/cicd/*
  + politique gérée AmazonEC2ContainerRegistryPowerUser ; mode "Privileged" coché.
Suite : ALB + target groups swiggy-tg-1/2 (type IP, port 3000), cluster Fargate, service blue/green.
INFO
