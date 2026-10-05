# Projet 01 — Application Java 3-tiers sur AWS

> Partie 1 — Fondations · Bible : chapitre « Projet 01 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Déployer une application Java (Spring MVC + MySQL) derrière Nginx et Tomcat sur une architecture 3-tiers AWS (golden AMI, ASG, NLB, RDS, Parameter Store).

## Ce que contient ce dossier

```text
app/.gitignore
app/HELP.md
app/README.md
app/mvnw
app/mvnw.cmd
app/pom.xml
app/settings.xml
db/schema.sql
fixes/README.md
fixes/sql-injection-et-session.patch
golden-ami/amazon-cloudwatch-agent.json
golden-ami/global.sh
golden-ami/maven.sh
golden-ami/nginx.sh
golden-ami/tomcat.service
golden-ami/tomcat.sh
ops/build-and-publish.sh
ops/create-alarm.sh
ops/put-parameters.sh
ops/ship-tomcat-logs.sh
user-data/nginx.sh
user-data/tomcat.sh
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- pom.xml : version du maven-war-plugin, propriétés Sonar, dépôt JFrog en variable
- application.properties lit SPRING_DATASOURCE_* (valeurs par défaut locales)
- settings.xml Maven sans secret (variables JFROG_USER / JFROG_TOKEN)
- fixes/ : correctif injection SQL (PreparedStatement), état partagé entre utilisateurs, pilote com.mysql.cj

## Ce qui a été vérifié avant livraison

- Build Maven (JDK 11) et exécution Tomcat 9 + MySQL 8.4 en conteneurs
- Démonstration de l'injection SQL et de l'état partagé sur la version d'origine, puis correction vérifiée (O'Brien fonctionne)
- shellcheck sur tous les scripts

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `app/pom.xml` : lignes 23, 24, 80
- `app/settings.xml` : ligne 15
- `ops/ship-tomcat-logs.sh` : ligne 4
- `user-data/nginx.sh` : ligne 4
- `user-data/tomcat.sh` : ligne 6

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 0 — Préparer le réseau
- [ ] Étape 1 — Les AMI : Global, puis trois Golden
- [ ] Étape 2 — Préparer JFrog et SonarCloud
- [ ] Étape 3 — Préparer le code de l'application
- [ ] Étape 4 — Construire et analyser
- [ ] Étape 5 — La base de données RDS
- [ ] Étape 6 — Le tier application (Tomcat)
- [ ] Étape 7 — Le tier présentation (Nginx)
- [ ] Étape 8 — Validation fonctionnelle
- [ ] Étape 9 — Post-déploiement : logs vers S3 et alarme
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

ASG (desired 0) puis suppression, NLB et target groups, RDS (sans snapshot final), AMI + snapshots, NAT Gateway, Elastic IP, paramètres SSM, alarmes CloudWatch.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
