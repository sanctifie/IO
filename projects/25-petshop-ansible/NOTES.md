# Projet 25 — Petshop : Jenkins + Ansible + K8s

> Partie 5 — DevSecOps · Bible : chapitre « Projet 25 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Pipeline Jenkins Maven/Sonar/OWASP qui délègue à Ansible la construction Docker et le déploiement Kubernetes.

## Ce que contient ce dossier

```text
.dockerignore
.gitattributes
.gitignore
Dockerfile
Dockerfile.original
Jenkinsfile
LICENSE
LICENSE_HEADER
NOTICE
README.md
deployment.yaml
format.xml
infra.tfvars
mvnw
mvnw.cmd
pom.xml
Ansible/docker.yaml
Ansible/hosts.example
Ansible/kube.yaml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Mot de passe Docker Hub en extraVars masquée + no_log (il était en clair)
- Conteneur relancé de façon idempotente (docker_container)
- Workspace et tag passés en variables ; kube.yaml sans delete (rolling update)
- Dockerfile multi-stage Tomcat 9 JRE 17 (openjdk déprécié)
- -Dlicense.skip=true : le plugin de licences exige un dépôt Git, absent dans un build Docker
- Service NodePort (LoadBalancer resterait pending sur kubeadm)

## Ce qui a été vérifié avant livraison

- Build Maven + 30 classes de tests
- WAR exécuté dans Tomcat 9/JRE 17 : catalogue affiché
- ansible-playbook --syntax-check
- Manifest en dry-run serveur
- terraform validate du lab

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `Ansible/hosts.example` : ligne 6
- `Jenkinsfile` : ligne 20
- `deployment.yaml` : ligne 19
- `infra.tfvars` : ligne 3

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

### Serveurs du lab

```bash
cd common/terraform-lab && terraform init
terraform apply   -var-file=../../projects/25-petshop-ansible/infra.tfvars -state=io-25.tfstate
terraform destroy -var-file=../../projects/25-petshop-ansible/infra.tfvars -state=io-25.tfstate
```

## Checklist (étapes de la bible)

- [ ] Étape 1 — Les instances avec Terraform
- [ ] Étape 2 — Le serveur Jenkins
- [ ] Étape 3 — Ansible sur le serveur Jenkins
- [ ] Étape 4 — Kubernetes
- [ ] Étape 5 — Adapter les playbooks
- [ ] Étape 6 — Le pipeline
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

terraform destroy (common/terraform-lab, io-25).

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
