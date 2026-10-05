#!/usr/bin/env bash
# Projet 22 — fournisseur OIDC GitHub + rôle IAM "github-serverless-deploy" limité à ton dépôt.
# Usage : GITHUB_REPO=<toi>/serverless-api ./setup-oidc.sh
set -euo pipefail
: "${GITHUB_REPO:?ex: GITHUB_REPO=moi/serverless-api}"
ROLE=github-serverless-deploy
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
PROVIDER="arn:aws:iam::$ACCOUNT:oidc-provider/token.actions.githubusercontent.com"
aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$PROVIDER" >/dev/null 2>&1 || \
  aws iam create-open-id-connect-provider --url https://token.actions.githubusercontent.com --client-id-list sts.amazonaws.com >/dev/null
# sub : la branche main (apply) ET les pull requests (plan) de TON dépôt uniquement
cat > /tmp/trust22.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "$PROVIDER" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
      "StringLike": { "token.actions.githubusercontent.com:sub": [
        "repo:$GITHUB_REPO:ref:refs/heads/main",
        "repo:$GITHUB_REPO:pull_request"
      ] }
    }
  }]
}
JSON
aws iam create-role --role-name "$ROLE" --assume-role-policy-document file:///tmp/trust22.json >/dev/null 2>&1 \
  || aws iam update-assume-role-policy --role-name "$ROLE" --policy-document file:///tmp/trust22.json
# Lab : PowerUserAccess + IAM (Terraform crée des rôles et politiques). En entreprise : politique sur mesure,
# et un rôle "plan" en lecture seule distinct du rôle "apply".
aws iam attach-role-policy --role-name "$ROLE" --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
aws iam attach-role-policy --role-name "$ROLE" --policy-arn arn:aws:iam::aws:policy/IAMFullAccess
echo "GitHub → Settings → Secrets and variables → Actions → secret AWS_ROLE_ARN = arn:aws:iam::$ACCOUNT:role/$ROLE"
