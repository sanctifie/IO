# Projet 22 — API serverless (Lambda, API Gateway, Aurora)

> Partie 4 — Serverless et services managés · Bible : chapitre « Projet 22 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

API Node.js sur Lambda dans un VPC, Aurora Serverless v2, Secrets Manager, S3, déployée par Terraform depuis GitHub Actions (OIDC).

## Ce que contient ce dossier

```text
.gitignore
backend.tf
domain.tf
main.tf
package-lambda.sh
provider.tf
terraform.tfvars
variables.tf
versions.tf
aws/setup-oidc.sh
serverless-api/.env.example
serverless-api/.gitignore
serverless-api/index.js
serverless-api/package.json
serverless-api/api/controllers/controller.js
serverless-api/api/controllers/delete.js
serverless-api/api/controllers/get.js
serverless-api/api/controllers/post.js
serverless-api/api/controllers/put.js
serverless-api/api/models/Product.js
serverless-api/api/models/ProductImage.js
serverless-api/api/models/User.js
serverless-api/api/routes/routes.js
serverless-api/api/services/service.js
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Runtime nodejs20.x, Aurora sans version figée, clé KMS avec rotation
- Domaine personnalisé optionnel (count), stage API Gateway en ressource dédiée, redéploiement quand les routes changent
- Mode local : DB_USER/DB_PASSWORD/DB_PORT au lieu de Secrets Manager ; fuseau UTC
- Workflow deploy.yml (plan sur PR, apply sur main, test de fumée)
- npm audit fix (2 critiques et 5 hautes corrigées)

## Ce qui a été vérifié avant livraison

- API testée sur MySQL 8.4 : /healthz 200, POST /user 201, GET /user/1 200 (auth basique), POST /product 201
- Handler Lambda invoqué localement (200)
- terraform validate
- actionlint, shellcheck

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `aws/setup-oidc.sh` : ligne 3
- `backend.tf` : ligne 3

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Lire et moderniser le code Terraform
- [ ] Étape 2 — Empaqueter la Lambda
- [ ] Étape 3 — Déployer à la main une première fois
- [ ] Étape 4 — La CI/CD avec GitHub Actions
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

terraform destroy (attendre la libération des ENI Lambda) ; vider le bucket S3 ; la clé KMS passe en suppression différée.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
