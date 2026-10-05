# Correctifs de sécurité (exercice bonus du projet 01)

L'application d'origine a deux failles, vérifiées en conditions réelles (Tomcat 9 + MySQL 8.4) :

| Faille | Démonstration | Cause |
|---|---|---|
| **Injection SQL** | mot de passe `' OR '1'='1` → connexion sans mot de passe | requête construite par concaténation de chaînes |
| **État partagé entre visiteurs** | après UNE connexion réussie, n'importe qui se connecte avec n'importe quel mot de passe | `userId` est un champ du contrôleur ; un contrôleur Spring est un singleton partagé par toutes les requêtes |

Le patch `sql-injection-et-session.patch` remplace les requêtes par des `PreparedStatement` et passe `userId`/`errorMessage` en variables locales. Bonus : les noms contenant une apostrophe (O'Brien) ne font plus planter l'inscription.

```bash
# depuis la racine du dépôt IO
git apply --directory=projects/01-java-3tier projects/01-java-3tier/fixes/sql-injection-et-session.patch
```

Fais-le sur une branche, pousse, et observe la Quality Gate SonarCloud passer au vert. Étape suivante : hacher les mots de passe (BCrypt).
