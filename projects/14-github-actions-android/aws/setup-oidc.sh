#!/usr/bin/env bash
# Projet 14 — fournisseur OIDC GitHub + rôle IAM limité au dépôt + bucket S3 des APK.
# Usage : GITHUB_REPO=<toi>/android-demo-app BUCKET=io-14-apk-<prenom> ./setup-oidc.sh
set -euo pipefail
: "${GITHUB_REPO:?ex: GITHUB_REPO=moi/android-demo-app}"; : "${BUCKET:?ex: BUCKET=io-14-apk-moi}"
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
PROVIDER="arn:aws:iam::$ACCOUNT:oidc-provider/token.actions.githubusercontent.com"
aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$PROVIDER" >/dev/null 2>&1 || \
  aws iam create-open-id-connect-provider --url https://token.actions.githubusercontent.com --client-id-list sts.amazonaws.com >/dev/null
cat > /tmp/trust.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "$PROVIDER" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
      "StringLike":   { "token.actions.githubusercontent.com:sub": "repo:$GITHUB_REPO:*" }
    }
  }]
}
JSON
aws iam create-role --role-name github-android-deploy --assume-role-policy-document file:///tmp/trust.json >/dev/null
aws iam put-role-policy --role-name github-android-deploy --policy-name put-apk --policy-document \
  "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:PutObject\",\"Resource\":\"arn:aws:s3:::$BUCKET/*\"}]}"
aws s3 mb "s3://$BUCKET" --region eu-west-3
echo "GitHub → Settings → Secrets : AWS_ROLE_ARN = arn:aws:iam::$ACCOUNT:role/github-android-deploy"
echo "GitHub → Settings → Variables : APK_BUCKET = $BUCKET ; SONAR_ORG ; SONAR_PROJECT_KEY  (+ secret SONAR_TOKEN)"
