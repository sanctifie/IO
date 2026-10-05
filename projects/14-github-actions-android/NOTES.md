# Projet 14 — GitHub Actions pour Android

> Partie 2 — CI/CD · Bible : chapitre « Projet 14 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Workflow GitHub Actions : tests unitaires, SonarCloud, build APK et publication sur S3 via OIDC.

## Ce que contient ce dossier

```text
.gitignore
build.gradle
gradle.properties
gradlew
gradlew.bat
settings.gradle
app/.gitignore
app/build.gradle
app/proguard-rules.pro
aws/setup-oidc.sh
first/.gitignore
first/build.gradle
first/consumer-rules.pro
first/proguard-rules.pro
gradle/wrapper/gradle-wrapper.jar
gradle/wrapper/gradle-wrapper.properties
scripts/email-commit.gradle
scripts/move-apk.gradle
scripts/my-logger.gradle
scripts/output-archive.gradle
scripts/root.gradle
scripts/version.gradle
second/.gitignore
second/build.gradle
second/consumer-rules.pro
second/proguard-rules.pro
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- local.properties et workflows inutiles supprimés, jcenter retiré
- Actions à jour (v4/v5), $GITHUB_OUTPUT, OIDC au lieu de clés AWS

## Ce qui a été vérifié avant livraison

- actionlint OK
- Build Android NON testé (dépôt Google Maven inaccessible depuis l'environnement de test)

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `aws/setup-oidc.sh` : ligne 3

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Préparer le dépôt
- [ ] Étape 2 — Le workflow, modernisé et commenté
- [ ] Étape 3 — SonarCloud
- [ ] Étape 4 — Où publier les APK ?
- [ ] Étape 5 — L'authentification OIDC entre GitHub et AWS
- [ ] Étape 6 — Tester la stratégie de branches
- [ ] Étape 7 (optionnelle) — Notifications
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Vider/supprimer le bucket des APK, le rôle IAM et le fournisseur OIDC s'il ne sert plus.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
