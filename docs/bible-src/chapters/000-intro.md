# Comment utiliser cette bible

<p class="lead">Cette bible accompagne le programme <strong>DevOps-Projects</strong> : 30 projets réels, classés du plus simple au plus avancé. Le dépôt d'origine donne surtout des listes de tâches (« crée un VPC », « installe Jenkins »…). Ici, chaque tâche est <strong>expliquée</strong> : ce qu'on fait, la commande exacte, et surtout <em>pourquoi</em> on le fait.</p>

## À qui s'adresse ce livre ?

À quelqu'un qui part de zéro, ou presque. Tu n'as pas besoin de savoir programmer, ni de connaître Linux, ni d'avoir déjà ouvert la console AWS. Il te faut :

- un ordinateur (Windows, macOS ou Linux) avec 8 Go de RAM au minimum ;
- une connexion Internet ;
- une carte bancaire (AWS et Azure la demandent, même pour l'offre gratuite) ;
- environ **6 à 9 mois** à raison de 8 à 10 heures par semaine pour tout le parcours ;
- de la curiosité, et la patience de relire un message d'erreur jusqu'au bout.

## Comment le livre est organisé

| Partie | Contenu | Projets |
|---|---|---|
| **0 — Avant de commencer** | Ce qu'est le DevOps, le cloud, préparer son poste, sécuriser son compte AWS, maîtriser ses coûts | — |
| **1 — Fondamentaux** | Leçons : Linux, réseau, AWS de base. Puis les premiers projets | 03, 02, 01 |
| **2 — Conteneurs & CI/CD** | Leçons : Git, Docker, CI/CD, Jenkins, Ansible. Puis les projets | 04, 05, 06, 07, 10, 14 |
| **3 — Kubernetes & IaC** | Leçons : Kubernetes, Terraform, Helm, GitOps. Puis les projets | 08, 11, 12, 15–20 |
| **4 — Cloud natif & Serverless** | Leçons : services managés AWS, serverless. Puis les projets | 21, 22, 26 |
| **5 — DevSecOps & Observabilité** | Leçons : sécurité de la chaîne logicielle, monitoring. Puis les projets | 09, 13, 23, 24, 25, 27–30 |
| **Annexes** | Recettes réutilisables (installer Jenkins, un cluster kubeadm…), aide-mémoire, glossaire | — |

Chaque projet suit **le même plan**, pour que tu saches toujours où tu en es :

1. **Fiche projet** : niveau, durée, coût estimé, compétences travaillées.
2. **Ce qu'on construit** : l'architecture, avec un schéma.
3. **Les concepts** à comprendre avant de taper la moindre commande.
4. **Pas à pas** : les étapes numérotées, chaque commande expliquée.
5. **Vérification** : comment prouver que ça marche.
6. **Dépannage** : les erreurs les plus fréquentes et leurs solutions.
7. **Nettoyage** : ce qu'il faut détruire pour ne pas payer.
8. **Pour aller plus loin** et **questions d'entretien**.

## Les encadrés

:::tip
Un raccourci, une bonne pratique, une façon plus confortable de faire.
:::

:::why
L'explication de fond. **Ne les saute pas** : c'est ce qui fait la différence entre quelqu'un qui recopie des commandes et un ingénieur DevOps.
:::

:::warn
Un piège classique dans lequel presque tout le monde tombe au moins une fois.
:::

:::danger
Un risque d'argent (une facture) ou de sécurité (une fuite de clés). À lire deux fois.
:::

:::clean
La liste de ce qu'il faut supprimer à la fin d'un projet. Un cluster Kubernetes oublié peut coûter plus de 150 € par mois.
:::

## Conventions dans les commandes

```bash
# Une ligne qui commence par # est un commentaire : elle n'est pas exécutée.
sudo apt update          # $ ou rien devant = commande à taper dans ton terminal
<MON_IP>                 # entre chevrons = à remplacer par TA valeur (sans les chevrons)
```

- Les commandes sont écrites pour **Ubuntu 24.04** (serveurs) et **Amazon Linux 2023** quand c'est précisé.
- La région AWS utilisée dans les exemples est **`eu-west-3` (Paris)**. Tu peux en choisir une autre, mais reste cohérent dans tout un projet.
- Quand une commande dépend d'un numéro de version (Kubernetes, Prometheus, SonarQube…), le livre utilise une variable comme `VERSION=…` et t'indique où trouver la dernière version. **Les versions changent vite ; la méthode, elle, reste la même.**

:::info Ce qui a changé depuis l'écriture du dépôt d'origine
Le dépôt DevOps-Projects date de 2022-2024. Certaines choses ont changé, et cette bible a été mise à jour en conséquence :

- **AWS CodeCommit** n'accepte plus de nouveaux clients (depuis juillet 2024) → on utilise GitHub avec **AWS CodeConnections**.
- **Azure DevOps Starter** a été retiré par Microsoft → on reconstruit le même pipeline à la main (c'est d'ailleurs plus formateur).
- Les **Launch Configurations** EC2 sont dépréciées → on utilise des **Launch Templates**.
- L'**offre gratuite AWS** a changé en juillet 2025 : les nouveaux comptes reçoivent des **crédits** (jusqu'à 200 $) valables 6 mois, et les instances éligibles sont les `t3.micro`/`t4g.micro` plutôt que `t2.micro`.
- Le backend S3 de **Terraform** sait maintenant verrouiller l'état sans DynamoDB (`use_lockfile = true`, Terraform 1.10 et plus).
- **SonarQube Community** s'appelle désormais **SonarQube Community Build**.
- **OWASP Dependency-Check** demande une clé d'API NVD (gratuite) pour ne pas mettre des heures à télécharger sa base.
:::

## La méthode de travail (à appliquer à chaque projet)

1. **Lis le projet en entier avant de commencer.** Comprends le schéma.
2. **Crée le dossier** `projects/NN-nom/` dans le dépôt IO, avec un fichier `NOTES.md`.
3. **Avance étape par étape.** Après chaque étape, vérifie que ça marche avant de passer à la suivante. Une erreur à l'étape 3 qu'on découvre à l'étape 9, c'est une heure perdue.
4. **Note tout** dans `NOTES.md` : les commandes, les erreurs rencontrées et comment tu les as résolues. Ce journal deviendra ton portfolio et ta mémoire.
5. **Commit souvent** (`git add`, `git commit`, `git push`).
6. **Nettoie** à la fin (encadré 🧹), puis vérifie la facturation le lendemain.
7. **Coche la case** dans le `README.md` du dépôt.
8. **Explique le projet à voix haute** en 3 minutes, comme en entretien. Si tu bloques, c'est que tu n'as pas encore tout compris : relis les encadrés 🧠.

:::tip Le modèle de NOTES.md
```markdown
# Projet NN — Titre

## Objectif (en une phrase, avec tes mots)

## Architecture (schéma ou description)

## Journal
### Jour 1 — date
- Fait : ...
- Problème : <message d'erreur exact>
- Cause : ...
- Solution : ...

## Ce que j'ai appris (5 points)

## Nettoyage effectué (liste + date)
```
:::

## Comment déboguer (la compétence n°1)

Un ingénieur DevOps passe une bonne partie de son temps à comprendre pourquoi quelque chose ne marche pas. Voici une méthode qui marche presque toujours :

1. **Lis le message d'erreur en entier**, en particulier la *dernière* ligne et la *première* ligne qui mentionne ton code ou ta configuration.
2. **Reformule le problème** : « le navigateur n'arrive pas à joindre le port 8080 de la machine X ».
3. **Remonte la chaîne, couche par couche.** Le service tourne-t-il (`systemctl status`) ? Écoute-t-il sur le bon port (`ss -tlnp`) ? Le pare-feu de la machine laisse-t-il passer ? Le *Security Group* AWS laisse-t-il passer ? L'IP est-elle la bonne ?
4. **Consulte les logs** : `journalctl -u <service>`, `docker logs`, `kubectl logs`, `kubectl describe`, la console du job Jenkins.
5. **Change une seule chose à la fois**, puis reteste.
6. **Cherche le message exact** sur Internet, entre guillemets. Tu n'es presque jamais le premier.
7. Si tu bloques plus de 45 minutes, **fais une pause** ou explique le problème à quelqu'un (ou à un canard en plastique). La moitié du temps, la solution apparaît pendant l'explication.

:::analogy Le modèle des « couches »
Un problème réseau, c'est comme une lettre qui n'arrive pas. Avant d'accuser le facteur, vérifie que l'adresse est juste, que la boîte aux lettres existe, que le nom est bien sur la boîte, et que personne n'a fermé le portail. On vérifie toujours **du plus simple au plus compliqué**, et **de l'intérieur vers l'extérieur** (d'abord sur la machine elle-même avec `curl localhost:8080`, puis depuis l'extérieur).
:::
