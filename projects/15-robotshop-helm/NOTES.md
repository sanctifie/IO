# Projet 15 — Robot Shop sur EKS avec Helm

> Partie 3 — Conteneurs, Kubernetes, IaC, GitOps · Bible : chapitre « Projet 15 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Déployer une application e-commerce microservices avec Helm, l'AWS Load Balancer Controller et le pilote EBS CSI.

## Ce que contient ce dossier

```text
cleanup.sh
ingress.yaml
setup.sh
storageclass-gp2.yaml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Ingress avec ingressClassName: alb
- StorageClass gp3 via ebs.csi.aws.com (gp2 in-tree obsolète)
- setup.sh / cleanup.sh complets

## Ce qui a été vérifié avant livraison

- helm template du chart Robot Shop + dry-run serveur

## À personnaliser avant de lancer

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Le cluster
- [ ] Étape 2 — Le fournisseur OIDC
- [ ] Étape 3 — Les droits IAM de l'AWS Load Balancer Controller
- [ ] Étape 4 — Installer le contrôleur avec Helm
- [ ] Étape 5 — Le pilote EBS CSI
- [ ] Étape 6 — Installer Robot Shop avec Helm
- [ ] Étape 7 — L'Ingress
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

./cleanup.sh (Ingress → ALB, PVC → volumes EBS, puis cluster).

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
