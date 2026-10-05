# Projet 09 — Netflix DevSecOps + monitoring

> Partie 5 — DevSecOps · Bible : chapitre « Projet 09 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Pipeline Jenkins DevSecOps (Sonar, OWASP DC, Trivy) pour un clone de Netflix, déploiement Docker puis Kubernetes, monitoring Prometheus/Grafana, e-mails.

## Ce que contient ce dossier

```text
Jenkinsfile
infra.tfvars
app/.dockerignore
app/.env.example
app/.gitignore
app/Dockerfile
app/index.html
app/package.json
app/tsconfig.json
app/tsconfig.node.json
app/vite.config.ts
app/Kubernetes/deployment.yml
app/Kubernetes/service.yml
monitoring/prometheus.yml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Clé TMDB lue dans un credential (elle était en clair dans le Jenkinsfile)
- Même nom d'image pour build, push et scan (l'original scannait une autre image)
- docker rm -f avant docker run ; tag = numéro de build
- Node 20 (outil Jenkins « node20 »), Dockerfile Node 20

## Ce qui a été vérifié avant livraison

- Build Vite de l'application (Node 22) et page servie par Nginx
- Manifests en dry-run serveur
- promtool check config

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `Jenkinsfile` : lignes 15, 25, 103
- `app/Kubernetes/deployment.yml` : ligne 19
- `infra.tfvars` : ligne 3
- `monitoring/prometheus.yml` : lignes 19, 24

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

### Serveurs du lab

```bash
cd common/terraform-lab && terraform init
terraform apply   -var-file=../../projects/09-netflix-devsecops/infra.tfvars -state=io-09.tfstate
terraform destroy -var-file=../../projects/09-netflix-devsecops/infra.tfvars -state=io-09.tfstate
```

## Checklist (étapes de la bible)

- [ ] Étape 1 — Le serveur principal
- [ ] Étape 2 — Jenkins, Docker, SonarQube, Trivy
- [ ] Étape 3 — La clé d'API TMDB
- [ ] Étape 4 — Le serveur de monitoring
- [ ] Étape 5 — Surveiller Jenkins avec Prometheus
- [ ] Étape 6 — Les notifications e-mail
- [ ] Étape 7 — Les plugins et outils du pipeline
- [ ] Étape 8 — Le pipeline
- [ ] Étape 9 — Kubernetes (master + worker) et déploiement
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Terminer les 4 instances (common/terraform-lab : terraform destroy -var-file=… -state=io-09.tfstate).

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
