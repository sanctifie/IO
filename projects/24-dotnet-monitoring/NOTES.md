# Projet 24 — .NET DevSecOps (Jenkins, K8s)

> Partie 5 — DevSecOps · Bible : chapitre « Projet 24 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Pipeline Jenkins DevSecOps pour une application ASP.NET de monitoring, déploiement Docker puis Kubernetes.

## Ce que contient ce dossier

```text
.dockerignore
.gitignore
Jenkinsfile
LICENSE
README.md
infra.tfvars
makefile
K8S/deployment.yaml
Properties/launchSettings.json
build/Dockerfile
build/installation-script.sh
tests/UnitTest.cs
tests/postman_collection.json
tests/tests.csproj
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Migration .NET 6 (fin de support) → .NET 8 LTS, paquets à jour, tests en net8.0
- Image runtime non-root (UID 1654), ENTRYPOINT en forme exec
- Nom d'image en minuscules, kubectl set image avec le numéro de build
- Probes et ressources

## Ce qui a été vérifié avant livraison

- dotnet test : 2 tests réussis
- Application lancée : /, /Info, /Monitor, /Tools, /api/monitor → 200
- Manifests en dry-run serveur

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `Jenkinsfile` : lignes 9, 19
- `K8S/deployment.yaml` : ligne 20
- `infra.tfvars` : ligne 3
- `makefile` : ligne 3

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

### Serveurs du lab

```bash
cd common/terraform-lab && terraform init
terraform apply   -var-file=../../projects/24-dotnet-monitoring/infra.tfvars -state=io-24.tfstate
terraform destroy -var-file=../../projects/24-dotnet-monitoring/infra.tfvars -state=io-24.tfstate
```

## Checklist (étapes de la bible)

- [ ] Étape 1 — Préparer le dépôt
- [ ] Étape 2 — Le serveur
- [ ] Étape 3 — Le pipeline
- [ ] Étape 4 — Kubernetes
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

terraform destroy (common/terraform-lab, io-24).

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
