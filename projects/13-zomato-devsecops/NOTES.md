# Projet 13 — Zomato DevSecOps

> Partie 5 — DevSecOps · Bible : chapitre « Projet 13 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Durcir un pipeline DevSecOps : image de production, contrôles bloquants (Quality Gate, Trivy), détection de secrets.

## Ce que contient ce dossier

```text
Jenkinsfile
infra.tfvars
app/.dockerignore
app/.gitignore
app/.trivyignore
app/Dockerfile
app/Dockerfile.original
app/package.json
k8s/zomato.yaml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Dockerfile multi-stage Nginx non-root (l'original lançait le serveur de DÉVELOPPEMENT dans une image ~1 Go)
- Quality Gate et Trivy CRITICAL bloquants (--ignore-unfixed), stage gitleaks, test de fumée
- Manifest Kubernetes non-root

## Ce qui a été vérifié avant livraison

- Build CRA (Node 22) ; image finale 97 Mo contre ~880 Mo pour l'équivalent d'origine ; utilisateur nginx (UID 101)
- gitleaks : aucun secret dans le code, fausse clé AWS bien détectée
- Manifest en dry-run serveur
- Trivy non exécuté ici (base de vulnérabilités inaccessible depuis l'environnement de test)

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `Jenkinsfile` : lignes 11, 21, 103
- `infra.tfvars` : ligne 3
- `k8s/zomato.yaml` : ligne 25

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

### Serveurs du lab

```bash
cd common/terraform-lab && terraform init
terraform apply   -var-file=../../projects/13-zomato-devsecops/infra.tfvars -state=io-13.tfstate
terraform destroy -var-file=../../projects/13-zomato-devsecops/infra.tfvars -state=io-13.tfstate
```

## Checklist (étapes de la bible)

- [ ] Étape 1 — L'infrastructure et les outils
- [ ] Étape 2 — Amélioration n°1 : un Dockerfile de production
- [ ] Étape 3 — Amélioration n°2 : des contrôles qui bloquent
- [ ] Étape 4 — Amélioration n°3 : la détection de secrets
- [ ] Étape 5 — Déploiement et vérification
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

terraform destroy (common/terraform-lab, io-13).

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
