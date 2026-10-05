@@part Partie 2 | Conteneurs & premiers pipelines CI/CD | Git en profondeur, Docker, les principes de la CI/CD, Jenkins et Ansible. Puis six projets : Django sur ECS, Jenkins + Docker, le grand pipeline « tous outils », Azure DevOps, .NET sur Azure et GitHub Actions.

# Leçon 4 — Git pour de vrai

Tu as déjà fait `clone`, `add`, `commit`, `push`. En DevOps, Git est **le point de départ de toute automatisation** : un `push` déclenche un pipeline, une *pull request* déclenche des tests, un commit sur un dépôt de configuration déclenche un déploiement (GitOps). Il faut le maîtriser.

## Le modèle mental

```ascii
 Répertoire de travail ──git add──► Zone de staging (index) ──git commit──► Dépôt local ──git push──► Dépôt distant (GitHub)
 (tes fichiers)                     (ce qui partira au commit)              (.git/)        ◄─git pull──
```

Un **commit** est une photo complète du projet à un instant donné, identifiée par un hash (`a3f9c1e…`), avec un auteur, une date, un message et un lien vers le commit parent. Une **branche** est simplement une étiquette mobile qui pointe vers un commit.

## Les commandes du quotidien

```bash
git status                       # que s'est-il passé ? (à taper tout le temps)
git diff                         # ce qui a changé et n'est pas encore "add"
git diff --staged                # ce qui partira au prochain commit
git add fichier   /  git add -p  # ajouter un fichier / choisir morceau par morceau
git commit -m "feat: ajoute le health check"
git log --oneline --graph --all  # l'historique en arbre
git switch -c feature/login      # créer une branche et s'y placer
git switch main                  # revenir sur main
git pull                         # récupérer et fusionner les changements distants
git push -u origin feature/login # publier la branche (et la suivre)
git merge feature/login          # fusionner une branche dans la branche courante
git restore fichier              # annuler les modifications non commitées d'un fichier
git revert <hash>                # créer un commit qui annule un commit précédent (sûr)
git stash / git stash pop        # mettre de côté des modifications en cours, puis les reprendre
git tag v1.0.0 && git push --tags   # marquer une version
```

## Les flux de travail (branching strategies)

**GitHub Flow** (le plus répandu, et celui qu'on utilise) :

1. `main` est toujours déployable.
2. Pour chaque changement, une branche courte : `feature/…`, `fix/…`.
3. On pousse la branche et on ouvre une **Pull Request** (PR, ou *Merge Request* sur GitLab).
4. La CI s'exécute automatiquement sur la PR ; un collègue relit (*code review*).
5. On fusionne dans `main`, ce qui déclenche le déploiement.

**Git Flow** (plus ancien, plus lourd) ajoute des branches `develop`, `release/*`, `hotfix/*`. Le projet 14 utilise des branches `develop`, `qa` et `main` qui correspondent à des environnements : c'est une variante.

**Trunk-based development** : tout le monde commite sur `main` (ou des branches de quelques heures), avec des *feature flags* pour masquer le travail en cours. C'est ce que font les équipes les plus rapides.

## Les bonnes pratiques

- **Petits commits, messages clairs.** Convention répandue (*Conventional Commits*) : `feat:`, `fix:`, `docs:`, `ci:`, `refactor:`, `chore:`.
- **Un `.gitignore` dès le premier commit** : jamais de `node_modules/`, `target/`, `.terraform/`, `*.tfstate`, `.env`, clés.
- **Protège `main`** : sur GitHub, *Settings → Branches → Add rule* : PR obligatoire, CI verte obligatoire.
- **Jamais de secret dans Git.** Si ça arrive : considère le secret comme compromis, **révoque-le immédiatement**. Le supprimer dans un nouveau commit ne suffit pas : il reste dans l'historique.

:::tip Les jetons d'accès (Personal Access Tokens)
Pour qu'un outil (Jenkins, Argo CD, un script) accède à GitHub, on n'utilise pas ton mot de passe mais un **jeton** : GitHub → *Settings → Developer settings → Personal access tokens → Fine-grained tokens*. Donne-lui **uniquement** les dépôts et droits nécessaires (par exemple *Contents: Read and write* sur un seul dépôt) et une date d'expiration.
:::

# Leçon 5 — Docker et les conteneurs

## Le problème

« Ça marche sur ma machine ! » Une application dépend de tout un environnement : une version précise de Python ou de Java, des bibliothèques système, des variables, des fichiers de configuration. Reproduire cet environnement sur chaque serveur est long et fragile.

## La solution : le conteneur

Un **conteneur** empaquette l'application **et tout ce dont elle a besoin** dans une unité standard qui tourne de la même façon partout où Docker est installé.

```ascii
     MACHINES VIRTUELLES                         CONTENEURS
 ┌───────┐ ┌───────┐ ┌───────┐          ┌───────┐ ┌───────┐ ┌───────┐
 │ App A │ │ App B │ │ App C │          │ App A │ │ App B │ │ App C │
 │ Libs  │ │ Libs  │ │ Libs  │          │ Libs  │ │ Libs  │ │ Libs  │
 │ OS    │ │ OS    │ │ OS    │          └───┬───┘ └───┬───┘ └───┬───┘
 │ invité│ │ invité│ │ invité│          ┌───┴─────────┴─────────┴───┐
 └───┬───┘ └───┬───┘ └───┬───┘          │   Moteur Docker           │
 ┌───┴─────────┴─────────┴───┐          ├────────────────────────────┤
 │      Hyperviseur          │          │   OS hôte (un seul noyau) │
 ├───────────────────────────┤          ├────────────────────────────┤
 │      Matériel             │          │   Matériel                │
 └───────────────────────────┘          └───────────────────────────┘
  lourd (Go), démarre en minutes          léger (Mo), démarre en secondes
```

Un conteneur n'embarque **pas** de système d'exploitation complet : il partage le noyau Linux de la machine hôte et s'isole grâce à des fonctions du noyau (*namespaces* pour l'isolement, *cgroups* pour limiter CPU et mémoire). D'où sa légèreté.

:::analogy Le conteneur maritime
Avant les conteneurs maritimes standardisés, charger un navire prenait des jours : chaque marchandise avait sa forme. Avec la boîte standard, peu importe ce qu'il y a dedans, toutes les grues, tous les bateaux et tous les camions savent la manipuler. Docker fait la même chose pour les logiciels.
:::

## Image, conteneur, registre

| Notion | Définition | Analogie |
|---|---|---|
| **Image** | un modèle en lecture seule, construit en couches (OS minimal + runtime + appli) | la recette, ou la classe en programmation |
| **Conteneur** | une instance en cours d'exécution d'une image | le plat cuisiné, ou l'objet |
| **Dockerfile** | le fichier texte qui décrit comment construire l'image | la fiche recette |
| **Registre** | un serveur qui stocke et distribue les images | la bibliothèque de recettes |
| **Tag** | la version d'une image : `nginx:1.27`, `monapp:v3`, `monapp:latest` | l'édition du livre |

Registres courants : **Docker Hub** (public), **Amazon ECR**, **Azure ACR**, **GitHub Container Registry**, **JFrog**, **Nexus**. Le nom complet d'une image indique où elle est stockée : `123456789012.dkr.ecr.eu-west-3.amazonaws.com/monapp:v3`.

## Le Dockerfile, ligne par ligne

```dockerfile
# 1. L'image de base : un Python officiel, version "slim" (allégée)
FROM python:3.12-slim

# 2. Le dossier de travail dans l'image (créé s'il n'existe pas)
WORKDIR /app

# 3. Copier D'ABORD la liste des dépendances, puis les installer
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copier ENSUITE le code
COPY . .

# 5. Documenter le port écouté par l'application
EXPOSE 8000

# 6. Ne pas tourner en root
RUN useradd -m appuser
USER appuser

# 7. La commande lancée au démarrage du conteneur
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```

:::why Pourquoi copier `requirements.txt` avant le code ?
Chaque instruction crée une **couche**, mise en **cache**. Si une couche n'a pas changé, Docker réutilise le cache et passe à la suivante. Le code change à chaque commit, les dépendances rarement. En copiant `requirements.txt` d'abord, l'étape `pip install` (lente) reste en cache tant que les dépendances ne bougent pas : le build passe de 2 minutes à 5 secondes.
:::

**Les instructions à connaître :** `FROM`, `WORKDIR`, `COPY` (préfère-le à `ADD`), `RUN`, `ENV` (variable d'environnement), `ARG` (variable disponible seulement pendant le build), `EXPOSE`, `USER`, `CMD` (commande par défaut, remplaçable au lancement), `ENTRYPOINT` (commande fixe), `HEALTHCHECK`.

**Le build multi-étapes** (*multi-stage*), utilisé dans plusieurs projets (Netflix, Swiggy) : une première étape avec tous les outils de compilation, une seconde ne contenant que le résultat. L'image finale est petite et ne contient pas les outils de build (moins de failles).

```dockerfile
# Étape 1 : construire l'application React
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Étape 2 : la servir avec Nginx (l'image finale ne contient ni Node ni les sources)
FROM nginx:stable-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
```

Ajoute toujours un fichier **`.dockerignore`** (même syntaxe que `.gitignore`) pour ne pas envoyer `node_modules`, `.git` ou des secrets dans le contexte de build.

## Les commandes Docker essentielles

```bash
docker build -t monapp:v1 .                 # construire l'image à partir du Dockerfile du dossier courant
docker images                               # lister les images locales
docker run -d --name web -p 8080:8000 monapp:v1
#          │   │          └─ port HÔTE:port CONTENEUR
#          │   └─ nom du conteneur
#          └─ détaché (en arrière-plan)
docker ps          /  docker ps -a          # conteneurs en cours / tous
docker logs -f web                          # suivre les logs
docker exec -it web bash                    # ouvrir un shell DANS le conteneur (ou sh)
docker stop web && docker rm web            # arrêter puis supprimer
docker rmi monapp:v1                        # supprimer l'image
docker tag monapp:v1 moncompte/monapp:v1    # donner un autre nom
docker login && docker push moncompte/monapp:v1
docker pull nginx:stable                    # télécharger une image
docker system prune -a                      # grand ménage (images, conteneurs arrêtés, cache)
```

:::warn Les données d'un conteneur sont éphémères
Quand on supprime un conteneur, tout ce qu'il a écrit dans son système de fichiers disparaît. Pour garder des données (une base de données, SonarQube, Jenkins), on utilise un **volume** : `docker run -v sonar_data:/opt/sonarqube/data …`. Tu le verras plusieurs fois.
:::

## Docker Compose

Pour lancer plusieurs conteneurs qui travaillent ensemble (une appli, sa base, un cache), on les décrit dans un fichier **`compose.yaml`** :

```yaml
services:
  web:
    build: .
    ports: ["8080:8000"]
    environment:
      DATABASE_URL: postgres://app:secret@db:5432/app
    depends_on: [db]
  db:
    image: postgres:16
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: app
    volumes: ["dbdata:/var/lib/postgresql/data"]
volumes:
  dbdata:
```

```bash
docker compose up -d      # tout démarrer
docker compose logs -f    # suivre les logs de tous les services
docker compose down       # tout arrêter (ajouter -v pour supprimer aussi les volumes)
```

Les services se joignent **par leur nom** (`db:5432`) : Compose crée un réseau privé avec un DNS interne. C'est la même idée que les *Services* Kubernetes.

## Installer Docker sur un serveur Ubuntu

Voir l'**annexe A.2** (installation depuis le dépôt officiel de Docker). Version rapide pour un serveur d'exercice :

```bash
sudo apt update && sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo usermod -aG docker $USER     # puis se déconnecter/reconnecter
docker run hello-world
```

:::danger Le groupe `docker` vaut root
Un utilisateur du groupe `docker` peut lancer `docker run -v /:/host …` et lire ou modifier n'importe quel fichier de la machine. Ajouter `jenkins` au groupe `docker` est courant sur un serveur de build, mais c'est un choix conscient : ce serveur doit être bien protégé. Et **jamais** `chmod 777 /var/run/docker.sock`.
:::

# Leçon 6 — La CI/CD

## Le pipeline

Un **pipeline** est une suite d'étapes automatiques exécutées à chaque changement de code. Il est lui-même décrit **dans un fichier versionné avec le code** (*pipeline as code*) : `Jenkinsfile`, `.github/workflows/*.yml`, `.gitlab-ci.yml`, `azure-pipelines.yml`, `buildspec.yml`.

```ascii
  git push
     │
     ▼
 ┌────────┐  ┌───────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐  ┌──────────┐  ┌────────┐
 │Checkout│─►│ Build │─►│Tests unit│─►│ Analyse  │─►│ Scan     │─►│ Image  │─►│ Publier  │─►│Déployer│
 │ le code│  │       │  │          │  │ qualité  │  │ sécurité │  │ Docker │  │ registre │  │        │
 └────────┘  └───────┘  └──────────┘  └──────────┘  └──────────┘  └────────┘  └──────────┘  └────────┘
                CI ◄──────────────────────────────────────────────────────────────►◄──── CD ────►
          Si une étape échoue, le pipeline s'arrête et l'équipe est prévenue.
```

## Les principes

1. **Le pipeline est la seule route vers la production.** Pas de déploiement manuel « juste cette fois ».
2. **Échouer vite** : les étapes rapides (compilation, tests unitaires) d'abord.
3. **Construire une seule fois, déployer partout** : le même artefact (même image, même tag) passe de test à production.
4. **Versionner les artefacts** de façon traçable : tag d'image = numéro de build ou hash du commit, jamais seulement `latest`.
5. **Les secrets ne sont jamais dans le pipeline en clair** : on utilise le coffre-fort de l'outil (*Jenkins Credentials*, *GitHub Secrets*, *Azure Key Vault*, *AWS Parameter Store*).
6. **Tout est reproductible** : les agents de build sont jetables (conteneurs, instances éphémères).

## Les déclencheurs

| Déclencheur | Quand | Exemple |
|---|---|---|
| **Webhook** (push) | GitHub prévient l'outil de CI à chaque push | le plus courant et le plus réactif |
| **Pull request** | à l'ouverture ou la mise à jour d'une PR | lancer les tests avant la fusion |
| **Poll SCM** | l'outil interroge le dépôt régulièrement | si le webhook est impossible (serveur non joignable) |
| **Planifié** (cron) | à heure fixe | scan de sécurité nocturne |
| **Manuel** | bouton | déploiement en production avec approbation |

## Les outils de CI/CD du parcours

| Outil | Hébergement | Fichier | Projets |
|---|---|---|---|
| **Jenkins** | toi (serveur à installer) | `Jenkinsfile` (Groovy) | 05, 06, 09, 16, 18, 19, 24, 25, 27, 28, 30 |
| **GitHub Actions** | GitHub (ou tes propres runners) | `.github/workflows/*.yml` | 14, 22 |
| **GitLab CI** | GitLab (ou tes runners) | `.gitlab-ci.yml` | 26 |
| **Azure Pipelines** | Azure DevOps (ou agents auto-hébergés) | `azure-pipelines.yml` | 07, 10, 17, 20, 29 |
| **AWS CodePipeline + CodeBuild** | AWS | `buildspec.yml` | 21, 23 |
| **Argo CD** (CD uniquement, GitOps) | dans ton cluster Kubernetes | manifests dans Git | 16, 18, 27, 29 |

Ils font tous la même chose avec une syntaxe différente. Quand tu en maîtrises un, les autres s'apprennent en quelques jours.

# Leçon 7 — Jenkins

**Jenkins** est le serveur d'automatisation open source historique. Il est très répandu en entreprise et omniprésent dans ce parcours.

## L'architecture

```ascii
            ┌──────────────────────────────┐
 Webhook ──►│  CONTRÔLEUR Jenkins (master) │  interface web :8080, planification, configuration,
 GitHub     │  plugins, credentials        │  stockage dans /var/lib/jenkins
            └───────┬──────────────┬────────┘
                    │ SSH / agent  │
            ┌───────▼──────┐ ┌─────▼────────┐
            │  AGENT 1     │ │  AGENT 2     │   exécutent les builds
            │  label maven │ │  label docker│   (Maven, Docker, kubectl installés dessus)
            └──────────────┘ └──────────────┘
```

Le **contrôleur** orchestre ; les **agents** (anciennement *slaves*) exécutent. En production, on met **0 exécuteur** sur le contrôleur : tous les builds tournent sur des agents (sécurité et performances). Les agents sont choisis grâce à des **labels**.

## Les notions

- **Job / Item** : une tâche configurée. Types : *Freestyle* (configuration par clics, ancien), **Pipeline** (un Jenkinsfile), **Multibranch Pipeline** (un pipeline par branche, découvert automatiquement).
- **Plugins** : presque tout passe par eux (Git, Docker, SonarQube, Kubernetes…). *Manage Jenkins → Plugins*.
- **Credentials** : le coffre-fort. On y range jetons et mots de passe, référencés par un **ID** dans le Jenkinsfile. *Manage Jenkins → Credentials*.
- **Tools** : les installations d'outils (JDK, Maven, scanner Sonar, Node.js…) déclarées par un nom. *Manage Jenkins → Tools*.
- **Workspace** : le dossier où le job récupère le code et travaille.

## Le Jenkinsfile déclaratif

```groovy
pipeline {
    agent { label 'maven' }               // sur quel agent exécuter

    tools {                               // outils déclarés dans "Manage Jenkins > Tools"
        jdk 'jdk17'
        maven 'maven3'
    }

    environment {                         // variables d'environnement
        IMAGE = "moncompte/monapp"
        DOCKERHUB = credentials('dockerhub')   // crée DOCKERHUB_USR et DOCKERHUB_PSW
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Checkout') {
            steps { git branch: 'main', url: 'https://github.com/moi/monapp.git' }
        }
        stage('Build & tests') {
            steps { sh 'mvn -B clean verify' }
        }
        stage('Image Docker') {
            steps {
                sh 'docker build -t $IMAGE:$BUILD_NUMBER .'
                sh 'echo $DOCKERHUB_PSW | docker login -u $DOCKERHUB_USR --password-stdin'
                sh 'docker push $IMAGE:$BUILD_NUMBER'
            }
        }
        stage('Déploiement') {
            when { branch 'main' }            // seulement sur main
            steps { sh './deploy.sh $BUILD_NUMBER' }
        }
    }

    post {                                // après les étapes, quel que soit le résultat
        success { echo 'Bravo' }
        failure { echo 'Échec : prévenir l\'équipe' }
        always  { cleanWs() }             // nettoyer le workspace
    }
}
```

Variables fournies par Jenkins : `BUILD_NUMBER`, `BUILD_URL`, `JOB_NAME`, `GIT_COMMIT`, `BRANCH_NAME` (en multibranch), `WORKSPACE`.

:::tip Le générateur de syntaxe
Dans un job Pipeline, le lien **Pipeline Syntax** ouvre un générateur : tu remplis un formulaire (par exemple « withCredentials »), il te donne la ligne Groovy à coller. Indispensable au début.
:::

L'installation complète de Jenkins est décrite en **annexe A.3** ; tu la feras dans le projet 05.

# Leçon 8 — Ansible

**Ansible** automatise la **configuration** des serveurs : installer des paquets, déposer des fichiers, démarrer des services. Il fonctionne **sans agent** : il se connecte en SSH depuis un **nœud de contrôle** et exécute des tâches décrites en YAML.

```ascii
 Nœud de contrôle (Ansible installé)
   │  inventaire : liste des serveurs
   │  playbook   : liste des tâches
   ├──SSH──► serveur web 1
   ├──SSH──► serveur web 2
   └──SSH──► serveur jenkins
```

## L'inventaire

```ini
# inventory.ini
[jenkins_master]
master ansible_host=10.0.1.10

[jenkins_agents]
agent1 ansible_host=10.0.1.20

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

## Un playbook

```yaml
# install-java.yml
- name: Préparer les agents Jenkins
  hosts: jenkins_agents
  become: true                      # exécuter en sudo
  tasks:
    - name: Installer Java 17 et Maven
      ansible.builtin.apt:
        name: [openjdk-17-jdk, maven, git]
        state: present              # "présent" : idempotent
        update_cache: true

    - name: Créer le dossier de travail
      ansible.builtin.file:
        path: /home/ubuntu/jenkins
        state: directory
        owner: ubuntu
```

```bash
ansible all -i inventory.ini -m ping               # tester la connexion à tous les serveurs
ansible-playbook -i inventory.ini install-java.yml # exécuter le playbook
```

:::why L'idempotence
On décrit **l'état voulu** (« Java doit être installé »), pas une suite d'actions (« installe Java »). Si Java est déjà là, Ansible ne fait rien et affiche `ok` au lieu de `changed`. On peut donc relancer un playbook 100 fois sans risque. C'est la même philosophie que Terraform (état voulu) et Kubernetes (état désiré).
:::

**Terraform vs Ansible** : Terraform **crée** l'infrastructure (VPC, instances, bases) ; Ansible **configure** l'intérieur des machines. On les utilise souvent ensemble (projet 06).

:::interview
- Différence entre une image et un conteneur ? Entre `CMD` et `ENTRYPOINT` ?
- Comment réduire la taille d'une image Docker ? *(Image de base slim/alpine, multi-stage, `.dockerignore`, regrouper les `RUN`, nettoyer les caches.)*
- Qu'est-ce qu'un pipeline CI/CD ? Quelles étapes y mets-tu ?
- Contrôleur et agent Jenkins : pourquoi séparer ?
- Qu'est-ce que l'idempotence en Ansible ?
:::
