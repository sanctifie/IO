# Projet 18 — GitOps Java (Jenkins, Sonar, Argo CD)

> Partie 3 — Conteneurs, Kubernetes, IaC, GitOps · Bible : chapitre « Projet 18 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Pipeline Jenkins pour une application Spring Boot avec mise à jour GitOps du manifest et synchronisation Argo CD.

## Ce que contient ce dossier

```text
local-cluster.sh
argocd/application.yaml
spring-boot-app/Dockerfile
spring-boot-app/JenkinsFile
spring-boot-app/README.md
spring-boot-app/pom.xml
spring-boot-app-manifests/deployment.yml
spring-boot-app-manifests/service.yml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Dockerfile eclipse-temurin:11-jre non-root
- sed par expression régulière (le tag précédent n'est plus supposé)
- local-cluster.sh

## Ce qui a été vérifié avant livraison

- Build du jar et de l'image
- Manifests et Application Argo CD en dry-run serveur

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `argocd/application.yaml` : ligne 9
- `spring-boot-app-manifests/deployment.yml` : ligne 19
- `spring-boot-app/JenkinsFile` : lignes 11, 12, 13

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Le serveur Jenkins + SonarQube
- [ ] Étape 2 — Préparer ton dépôt
- [ ] Étape 3 — Les credentials Jenkins
- [ ] Étape 4 — Le Jenkinsfile, adapté
- [ ] Étape 5 — Argo CD sur un cluster local
- [ ] Étape 6 — Boucle complète
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Supprimer l'Application Argo CD, le cluster local ou cloud, l'instance Jenkins.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
