# Projet 03 — Linux pour le Cloud & DevOps

> Partie 1 — Fondations · Bible : chapitre « Projet 03 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Maîtriser les commandes Linux essentielles : utilisateurs, groupes, permissions, sudo, disques EBS, montage persistant.

## Ce que contient ce dossier

```text
create-ebs.sh
mount-ebs.sh
setup.sh
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- setup.sh rejouable (fichier sudoers temporaire supprimé automatiquement)
- mount-ebs.sh refuse un disque non vide et monte par UUID avec nofail

## Ce qui a été vérifié avant livraison

- setup.sh exécuté de bout en bout dans un conteneur Ubuntu 24.04
- shellcheck

## À personnaliser avant de lancer

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 0 — Lancer l'instance
- [ ] Étape 1 — En tant que super-utilisateur
- [ ] Étape 2 — En tant que user1
- [ ] Étape 3 — En tant que user4
- [ ] Étape 4 — En tant que user1
- [ ] Étape 5 — En tant que user2
- [ ] Étape 6 — En tant que root
- [ ] Étape 7 — Créer et attacher un volume EBS de 5 Go
- [ ] Étape 8 — Créer le système de fichiers et monter le disque
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Détacher et supprimer le volume EBS, terminer l'instance.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
