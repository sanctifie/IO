# Projet 05 — Jenkins + Docker

> Partie 2 — CI/CD · Bible : chapitre « Projet 05 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Construire un .war avec Jenkins et le déployer dans un conteneur Tomcat sur un hôte Docker via SSH.

## Ce que contient ce dossier

```text
Dockerfile
Jenkinsfile
pom.xml
regapp-deploy.yml
regapp-service.yml
server/pom.xml
setup/dockerhost.sh
setup/jenkins-key.sh
webapp/pom.xml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- pom : maven-compiler 3.13 / release 8 (Java 1.7 refusé par les JDK récents)
- Dockerfile tomcat:9.0-jdk17, docker rm -f || true (rejouable)
- Déclenchement par webhook GitHub

## Ce qui a été vérifié avant livraison

- Build Maven (JDK 21) et image Tomcat testés
- shellcheck

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `Jenkinsfile` : ligne 11

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Le serveur Jenkins
- [ ] Étape 2 — L'hôte Docker
- [ ] Étape 3 — Préparer le dépôt GitHub
- [ ] Étape 4 — La clé SSH Jenkins → hôte Docker
- [ ] Étape 5 — Le job et le webhook
- [ ] Étape 6 — Le test de bout en bout
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Terminer les deux instances, supprimer le Security Group.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
