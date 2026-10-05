# Projet 06 — CI/CD avancé (Terraform, Ansible, Jenkins, Sonar, JFrog, EKS)

> Partie 2 — CI/CD · Bible : chapitre « Projet 06 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Assembler une chaîne complète : infra Terraform, configuration Ansible, Jenkins maître/agent, SonarCloud, JFrog, Docker, Helm sur EKS.

## Ce que contient ce dossier

```text
ansible/ansible.cfg
ansible/hosts.ini.example
ansible/jenkins-agent.yml
ansible/jenkins-master.yml
app/Dockerfile
app/Jenkinsfile
app/pom.xml
app/sonar-project.properties
app/sample-app/.helmignore
app/sample-app/Chart.yaml
app/sample-app/values.yaml
eks/cluster.yaml
eks/setup-partie-b.sh
terraform/main.tf
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- JaCoCo 0.8.12, image eclipse-temurin:8-jre non-root
- Chart Helm sans secret ni variables Twitter en dur
- Sortie Terraform qui génère l'inventaire Ansible
- Déploiement EKS derrière un paramètre DEPLOY_TO_EKS

## Ce qui a été vérifié avant livraison

- terraform validate, ansible --syntax-check, helm lint/template, build + exécution de l'app (JDK 21)

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `app/Jenkinsfile` : lignes 4, 5
- `app/sample-app/values.yaml` : lignes 4, 7
- `app/sonar-project.properties` : lignes 1, 2

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Partie A — Infrastructure, configuration et CI
- [ ] Partie B — Kubernetes et monitoring
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

eksctl delete cluster, terraform destroy, dépôts JFrog/SonarCloud si inutiles.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
