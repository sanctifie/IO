# Projet 27 — Reddit sur EKS + Argo CD + monitoring

> Partie 5 — DevSecOps · Bible : chapitre « Projet 27 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Jenkins construit l'image, met à jour le manifest ; Argo CD déploie sur EKS derrière un ALB ; kube-prometheus-stack pour l'observabilité.

## Ce que contient ce dossier

```text
app/.dockerignore
app/.env.example
app/.gitignore
app/Dockerfile
app/next-env.d.ts
app/next.config.js
app/package.json
app/tsconfig.json
app/EKS-TF/backend.tf
app/EKS-TF/data.tf
app/EKS-TF/eks.tf
app/EKS-TF/provider.tf
app/EKS-TF/variables.tf
app/EKS-TF/variables.tfvars
app/EKS-TF/vpc.tf
app/Jenkins-Pipeline-Code/Jenkinsfile-EKS-Terraform
app/Jenkins-Pipeline-Code/Jenkinsfile-Reddit
app/K8s/deployment.yml
app/K8s/ingress.yml
app/K8s/service.yml
argocd/application.yaml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Dockerfile de production (next build + next start, non-root) au lieu de « npm run dev » sur node:19
- Config Firebase sortie du code (.env.production via credential Jenkins)
- Bug corrigé : getServerSideProps sans return → erreur 500
- Trivy sur l'image construite (et non :latest)
- Ingress ALB sans host ni chemin /test
- EKS-TF = module du projet 19 (au lieu de dépendre du VPC Jenkins)
- Le dossier Jenkins-server-TF existe bien dans le dépôt (la bible le dit vide) : on garde quand même le serveur du projet 19, avec rôle IAM

## Ce qui a été vérifié avant livraison

- Build Next.js de production et conteneur testés (/ et /r/test → 200, utilisateur node)
- Manifests et Application Argo CD en dry-run serveur
- Substitution sed vérifiée

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `app/EKS-TF/backend.tf` : ligne 3
- `app/Jenkins-Pipeline-Code/Jenkinsfile-EKS-Terraform` : ligne 16
- `app/Jenkins-Pipeline-Code/Jenkinsfile-Reddit` : lignes 14, 15
- `app/K8s/deployment.yml` : ligne 20
- `argocd/application.yaml` : ligne 9

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Le serveur Jenkins avec Terraform
- [ ] Étape 2 — Le cluster EKS par un pipeline
- [ ] Étape 3 — Le pipeline applicatif
- [ ] Étape 4 — Argo CD
- [ ] Étape 5 — Monitoring avec Prometheus et Grafana
- [ ] Étape 6 — Analyser et interpréter les métriques
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Supprimer l'Application Argo CD et l'Ingress (ALB), puis pipeline EKS action=destroy, puis le serveur Jenkins.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
