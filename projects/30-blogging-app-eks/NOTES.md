# Projet 30 — Projet final : Blog sur EKS (Nexus, Sonar, Trivy, monitoring)

> Partie 5 — DevSecOps · Bible : chapitre « Projet 30 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Chaîne complète : Maven → Sonar → Nexus → image privée → EKS avec un ServiceAccount limité, e-mails, sondes Blackbox.

## Ce que contient ce dossier

```text
Jenkinsfile
infra.tfvars
EKS-TF/backend.tf
EKS-TF/data.tf
EKS-TF/eks.tf
EKS-TF/provider.tf
EKS-TF/variables.tf
EKS-TF/variables.tfvars
EKS-TF/vpc.tf
app/.gitignore
app/Dockerfile
app/deployment-service.yml
app/pom.xml
jenkins/maven-settings.xml
k8s/rbac-jenkins.yaml
monitoring/alerts.yml
monitoring/blackbox.yml
monitoring/prometheus.yml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Bloc post placé hors du pipeline dans l'original (erreur de syntaxe) : corrigé
- Image taguée par build, IMAGE_TAG remplacé au déploiement
- RBAC limité aux ressources utiles (l'original : * sur *)
- Console H2 désactivée
- Image JRE non-root ; mvnw retiré (dossier .mvn absent du dépôt)
- settings.xml Maven sans mot de passe (Server Credentials)
- Alertes Prometheus (site injoignable / lent)

## Ce qui a été vérifié avant livraison

- mvn package (tests OK), application lancée (/register 200)
- RBAC appliqué sur k3s : déploiement réussi AVEC le jeton Jenkins, accès refusé aux nœuds et au namespace default
- promtool + blackbox --config.check
- Nexus 3.96 testé : envoi refusé (403) tant que l'EULA Community n'est pas acceptée → accepte-la dans l'assistant de première connexion

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `EKS-TF/backend.tf` : ligne 3
- `Jenkinsfile` : lignes 13, 23, 101
- `app/deployment-service.yml` : ligne 18
- `app/pom.xml` : lignes 105, 109
- `infra.tfvars` : ligne 3

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

### Serveurs du lab

```bash
cd common/terraform-lab && terraform init
terraform apply   -var-file=../../projects/30-blogging-app-eks/infra.tfvars -state=io-30.tfstate
terraform destroy -var-file=../../projects/30-blogging-app-eks/infra.tfvars -state=io-30.tfstate
```

## Checklist (étapes de la bible)

- [ ] Étape 1 — Le dépôt et le token GitHub
- [ ] Étape 2 — Les serveurs
- [ ] Étape 3 — Jenkins, SonarQube et Nexus
- [ ] Étape 4 — Plugins, outils et configurations
- [ ] Étape 5 — Le pipeline CI
- [ ] Étape 6 — EKS, RBAC et déploiement
- [ ] Étape 7 — Un domaine personnalisé (optionnel)
- [ ] Étape 8 — Le monitoring de l'application
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Service LoadBalancer, cluster (EKS-TF), puis les 4 instances (common/terraform-lab, io-30).

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
