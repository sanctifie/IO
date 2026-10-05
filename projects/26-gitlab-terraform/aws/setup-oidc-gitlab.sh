#!/usr/bin/env bash
# Projet 26, étape 6 — fournisseur OIDC gitlab.com + rôle "gitlab-terraform" limité à ton projet et à main.
# Usage : GITLAB_PROJECT=<toi>/aws-terraform-gitlab STATE_BUCKET=io-tfstate-<prenom> ./setup-oidc-gitlab.sh
set -euo pipefail
: "${GITLAB_PROJECT:?ex: GITLAB_PROJECT=moi/aws-terraform-gitlab}"
: "${STATE_BUCKET:?ex: STATE_BUCKET=io-tfstate-moi}"
ROLE=gitlab-terraform
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
PROVIDER="arn:aws:iam::$ACCOUNT:oidc-provider/gitlab.com"

aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$PROVIDER" >/dev/null 2>&1 || \
  aws iam create-open-id-connect-provider --url https://gitlab.com --client-id-list https://gitlab.com >/dev/null

cat > /tmp/trust26.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "$PROVIDER" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": { "gitlab.com:aud": "https://gitlab.com" },
      "StringLike": { "gitlab.com:sub": "project_path:$GITLAB_PROJECT:ref_type:branch:ref:main" }
    }
  }]
}
JSON
aws iam create-role --role-name "$ROLE" --assume-role-policy-document file:///tmp/trust26.json >/dev/null 2>&1 \
  || aws iam update-assume-role-policy --role-name "$ROLE" --policy-document file:///tmp/trust26.json

# Droits : EC2/VPC complet + lecture/écriture de l'état dans le bucket
aws iam attach-role-policy --role-name "$ROLE" --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
cat > /tmp/state26.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "s3:ListBucket", "Resource": "arn:aws:s3:::$STATE_BUCKET" },
    { "Effect": "Allow", "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::$STATE_BUCKET/terraform/*" }
  ]
}
JSON
aws iam put-role-policy --role-name "$ROLE" --policy-name tfstate --policy-document file:///tmp/state26.json
echo "AWS_ROLE_ARN = arn:aws:iam::$ACCOUNT:role/$ROLE   (à reporter dans .gitlab-ci.oidc.yml)"
