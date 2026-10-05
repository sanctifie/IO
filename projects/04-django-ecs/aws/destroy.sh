#!/usr/bin/env bash
# Projet 04 — supprime tout ce que créent push-ecr.sh et deploy-ecs.sh
set -uo pipefail
export AWS_DEFAULT_REGION="${AWS_REGION:-eu-west-3}"
aws ecs update-service --cluster io-django-cluster --service django-service --desired-count 0 >/dev/null 2>&1
aws ecs delete-service --cluster io-django-cluster --service django-service --force >/dev/null 2>&1
aws ecs wait services-inactive --cluster io-django-cluster --services django-service 2>/dev/null
aws ecs delete-cluster --cluster io-django-cluster >/dev/null 2>&1
for td in $(aws ecs list-task-definitions --family-prefix django-task --query 'taskDefinitionArns[]' --output text); do
  aws ecs deregister-task-definition --task-definition "$td" >/dev/null
done
aws ecr delete-repository --repository-name hello-world-django-app --force >/dev/null 2>&1
aws logs delete-log-group --log-group-name /ecs/django-task 2>/dev/null
VPC=$(aws ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text)
SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=django-sg Name=vpc-id,Values="$VPC" --query 'SecurityGroups[0].GroupId' --output text)
[ "$SG" != "None" ] && aws ec2 delete-security-group --group-id "$SG"
echo "Nettoyage terminé (le rôle ecsTaskExecutionRole est conservé, il est gratuit)."
