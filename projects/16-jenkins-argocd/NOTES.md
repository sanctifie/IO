# Projet 16 — Jenkins → Kubernetes avec Argo CD

> Partie 3 — Conteneurs, Kubernetes, IaC, GitOps · Bible : chapitre « Projet 16 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

CI Jenkins (Maven, Sonar, Trivy, image) qui met à jour un dépôt GitOps ; Argo CD déploie sur Kubernetes.

## Ce que contient ce dossier

```text
argocd/application.yaml
argocd/install.sh
ci/Dockerfile
ci/Jenkinsfile
ci/README.md
ci/pom.xml
ci/server/pom.xml
ci/webapp/pom.xml
gitops/Jenkinsfile
gitops/deployment.yaml
gitops/service.yaml
sonarqube/compose.yaml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Scans sur la bonne image (IMAGE_TAG)
- Déclenchement CD avec curl -f
- sed qui remplace n'importe quel tag
- requests/limits et readinessProbe
- SonarQube compose avec mot de passe obligatoire

## Ce qui a été vérifié avant livraison

- Build Maven + image testés
- Manifests et Application Argo CD validés en dry-run serveur (CRD Argo CD installées)

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `argocd/application.yaml` : ligne 10
- `ci/Jenkinsfile` : lignes 13, 17, 18, 27
- `gitops/Jenkinsfile` : ligne 7
- `gitops/deployment.yaml` : ligne 17

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Jenkins master et agent
- [ ] Étape 2 — Le pipeline CI
- [ ] Étape 3 — SonarQube auto-hébergé
- [ ] Étape 4 — Le cluster EKS et le serveur bootstrap
- [ ] Étape 5 — Argo CD
- [ ] Étape 6 — Le dépôt GitOps et le pipeline CD
- [ ] Étape 7 — Le test de bout en bout
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Supprimer l'Application Argo CD, le cluster, les instances Jenkins/Sonar.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
