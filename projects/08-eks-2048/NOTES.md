# Projet 08 — EKS : le jeu 2048

> Partie 3 — Conteneurs, Kubernetes, IaC, GitOps · Bible : chapitre « Projet 08 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Créer un cluster EKS avec eksctl et y exposer le jeu 2048 (Pod, Deployment, Service LoadBalancer).

## Ce que contient ce dossier

```text
cleanup.sh
deploy.sh
eks/cluster.yaml
k8s/2048-deploy.yaml
k8s/2048-pod.yaml
k8s/mygame-svc.yaml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Manifests avec requests/limits et probes
- Scripts deploy.sh / cleanup.sh

## Ce qui a été vérifié avant livraison

- kubectl apply --dry-run=server sur k3s
- shellcheck

## À personnaliser avant de lancer

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Partie 1 — La méthode console (pour comprendre)
- [ ] Partie 2 — La même chose en une commande avec eksctl
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

./cleanup.sh (supprime le Service AVANT le cluster pour libérer le load balancer).

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
