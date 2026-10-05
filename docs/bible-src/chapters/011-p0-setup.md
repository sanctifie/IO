# Préparer ton poste de travail

Tout au long du parcours, tu vas travailler dans un **terminal** et un **éditeur de code**. Installons-les proprement une fois pour toutes.

## Étape 1 — Un terminal Linux

La quasi-totalité des serveurs du cloud tournent sous Linux. Autant travailler dans le même environnement.

**Sous Windows : installe WSL2** (*Windows Subsystem for Linux*). C'est un vrai Ubuntu qui tourne dans Windows.

```powershell
# Dans PowerShell lancé "en tant qu'administrateur"
wsl --install -d Ubuntu-24.04
# Redémarre l'ordinateur, puis lance "Ubuntu" depuis le menu Démarrer.
# Il te demande de créer un nom d'utilisateur et un mot de passe Linux.
```

Installe aussi **Windows Terminal** (Microsoft Store) : plus confortable que l'ancienne console.

**Sous macOS** : le Terminal est déjà là. Installe le gestionnaire de paquets **Homebrew** (instructions sur `brew.sh`), qui permet d'installer tous les outils avec `brew install …`.

**Sous Linux** : tu as déjà tout. Les commandes de ce livre sont pour Ubuntu/Debian.

:::check
Ouvre ton terminal et tape `uname -a`. Sous WSL ou Linux, tu dois voir `Linux` dans la réponse. Sous macOS, `Darwin`.
:::

## Étape 2 — Les outils de base

Dans ton terminal Ubuntu (WSL ou Linux) :

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget unzip jq tree vim nano ca-certificates gnupg make python3-pip
```

- `sudo` : exécuter la commande en tant qu'administrateur (*superuser do*). Il demande ton mot de passe Linux.
- `apt` : le gestionnaire de paquets d'Ubuntu, l'équivalent d'un « App Store » en ligne de commande.
- `jq` : un outil pour lire et filtrer du JSON (les réponses de l'AWS CLI sont en JSON).

Sous macOS : `brew install git curl wget jq tree`.

## Étape 3 — Visual Studio Code

Télécharge **VS Code** sur `code.visualstudio.com`. Extensions recommandées :

| Extension | Pourquoi |
|---|---|
| **WSL** (Windows uniquement) | Ouvrir les dossiers de WSL directement : tape `code .` dans le terminal Ubuntu |
| **HashiCorp Terraform** | Coloration et autocomplétion des fichiers `.tf` |
| **YAML** (Red Hat) | Valide les fichiers YAML (Kubernetes, pipelines) |
| **Docker** / **Kubernetes** | Explorer conteneurs et clusters |
| **GitLens** | Voir l'historique Git ligne par ligne |
| **AWS Toolkit** | Parcourir tes ressources AWS |

## Étape 4 — Configurer Git et GitHub

```bash
git config --global user.name "Ton Nom"
git config --global user.email "ton.email@exemple.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
```

Crée ensuite une **clé SSH** pour t'authentifier auprès de GitHub sans taper de mot de passe :

```bash
ssh-keygen -t ed25519 -C "ton.email@exemple.com"
# Appuie sur Entrée pour accepter l'emplacement par défaut (~/.ssh/id_ed25519)
# Choisis une "passphrase" (un mot de passe qui protège la clé)
cat ~/.ssh/id_ed25519.pub
```

Copie la ligne affichée (elle commence par `ssh-ed25519`) et colle-la sur GitHub : **Settings → SSH and GPG keys → New SSH key**.

:::why Comment marche une clé SSH ?
Une paire de clés, c'est un **cadenas** et sa **clé**. La clé **publique** (`.pub`) est le cadenas : tu peux la distribuer à qui tu veux (GitHub, des serveurs). La clé **privée** (sans extension) est la seule capable d'ouvrir ce cadenas : **elle ne quitte jamais ta machine et ne se partage jamais**. Quand tu te connectes, le serveur te lance un défi que seule la clé privée peut résoudre. Tu retrouveras exactement ce mécanisme avec les *key pairs* EC2, les agents Jenkins et Ansible.
:::

```bash
ssh -T git@github.com
# Réponse attendue : "Hi <ton-pseudo>! You've successfully authenticated..."
git clone git@github.com:sanctifie/IO.git
cd IO
```

Active aussi la **double authentification (2FA)** sur GitHub (Settings → Password and authentication).

## Étape 5 — Les outils DevOps (à installer au fur et à mesure)

Tu n'as pas besoin de tout installer aujourd'hui : chaque projet indique ce qu'il lui faut. Voici les commandes de référence pour Ubuntu/WSL :

```bash
# --- AWS CLI v2 ---
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip && sudo ./aws/install && rm -rf aws awscliv2.zip
aws --version

# --- Terraform (dépôt officiel HashiCorp) ---
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
terraform -version

# --- kubectl (binaire officiel, dernière version stable) ---
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl
kubectl version --client

# --- eksctl ---
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/ && eksctl version

# --- Helm ---
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

**Docker** : sous Windows/macOS, installe **Docker Desktop** (il s'intègre à WSL2 : coche *Use the WSL 2 based engine*). Sous Linux, voir l'annexe A.

:::tip Pourquoi `curl … | bash` est à manier avec précaution
`curl URL | bash` télécharge un script et l'exécute immédiatement, sans que tu le lises. C'est pratique, mais tu fais une confiance totale à l'URL. Ne le fais qu'avec des sources officielles (ici, le dépôt de Helm). En entreprise, on préfère télécharger le script, le lire, puis l'exécuter.
:::

# Ouvrir et sécuriser ton compte AWS

C'est l'étape la plus importante de toute la partie 0. Un compte AWS mal sécurisé peut te coûter des milliers d'euros. Prends 45 minutes pour la faire sérieusement.

## Étape 1 — Créer le compte

1. Va sur `aws.amazon.com` → **Create an AWS Account**.
2. Utilise une adresse e-mail dédiée (par exemple `prenom+aws@gmail.com`) et un mot de passe long et unique (gestionnaire de mots de passe recommandé).
3. Choisis le type de compte **Personal**.
4. Renseigne ta carte bancaire. AWS fait une pré-autorisation de 1 $ environ.
5. Choisis le plan **Free** (gratuit) si on te le propose : il te donne des crédits et **bloque les services les plus chers** tant que tu ne passes pas au plan payant. Pour les projets avancés (EKS, NAT Gateway…), tu devras passer au plan payant : ce sera le moment de relire la section sur les coûts.

:::info L'offre gratuite AWS depuis juillet 2025
Les nouveaux comptes reçoivent **100 $ de crédits** à l'ouverture, plus jusqu'à **100 $** supplémentaires en réalisant des petites missions d'initiation dans la console (lancer une instance EC2, créer un budget…). Le plan gratuit dure **6 mois** ou jusqu'à épuisement des crédits. Les conditions évoluent : vérifie la page *AWS Free Tier* au moment où tu ouvres ton compte. Dans tous les cas, **les crédits ne remplacent pas les alertes de budget** : configure-les quand même.
:::

## Étape 2 — Protéger le compte root

Le compte avec lequel tu viens de t'inscrire est le **root** : il a tous les droits, y compris fermer le compte et changer la carte bancaire. On ne l'utilise **presque jamais**.

1. Connecte-toi en root → en haut à droite, ton nom → **Security credentials**.
2. Section **Multi-factor authentication (MFA)** → **Assign MFA device** → *Authenticator app* (Google Authenticator, Microsoft Authenticator, Authy, 1Password…), ou mieux, une clé physique (YubiKey).
3. Vérifie qu'il n'existe **aucune access key** pour le root. S'il y en a une, supprime-la.

:::danger Règle d'or
**Jamais d'access key sur le compte root. Jamais.** Et MFA obligatoire. Le root ne sert qu'à quelques actions rares (facturation, fermeture du compte).
:::

## Étape 3 — Créer ton utilisateur d'administration

Deux options. La première est la méthode recommandée par AWS aujourd'hui ; la seconde est plus simple et suffit pour apprendre.

**Option A (recommandée) : IAM Identity Center.**

1. Console → service **IAM Identity Center** → *Enable*.
2. **Users → Add user** : ton prénom, ton e-mail.
3. **Permission sets → Create** → *Predefined* → `AdministratorAccess`.
4. **AWS accounts** → coche ton compte → *Assign users* → ton utilisateur + le permission set.
5. Tu reçois un e-mail d'invitation. Tu obtiens une **URL de portail d'accès** (de la forme `https://d-xxxxxxxxxx.awsapps.com/start`) : mets-la en favori, c'est désormais par là que tu te connectes. Active la MFA à la première connexion.

Côté terminal :

```bash
aws configure sso
# SSO session name : io
# SSO start URL    : https://d-xxxxxxxxxx.awsapps.com/start
# SSO region       : eu-west-3 (ou la région où tu as activé Identity Center)
# -> une page s'ouvre dans le navigateur pour valider
# Default client Region : eu-west-3
# Default output format : json
# Profile name          : io-admin

aws sts get-caller-identity --profile io-admin
export AWS_PROFILE=io-admin       # pour ne pas répéter --profile
aws sso login                     # à refaire quand la session expire
```

**Option B (plus simple) : un utilisateur IAM classique.**

1. Console → **IAM → Users → Create user** → nom `admin-<prenom>`, coche *Provide user access to the AWS Management Console*.
2. *Attach policies directly* → `AdministratorAccess`.
3. Connecte-toi avec cet utilisateur (URL de connexion du compte affichée sur le tableau de bord IAM) et **active sa MFA**.
4. Pour le terminal : *Security credentials* → **Create access key** → *Command Line Interface*.

```bash
aws configure
# AWS Access Key ID     : AKIA...
# AWS Secret Access Key : ********
# Default region name   : eu-west-3
# Default output format : json
aws sts get-caller-identity
```

Les clés sont stockées dans `~/.aws/credentials`.

:::danger Protéger tes access keys
- Ne les mets **jamais** dans un fichier versionné par Git, ni dans un Dockerfile, ni dans un script partagé, ni dans une capture d'écran.
- Ajoute ce fichier `.gitignore` à la racine du dépôt IO dès maintenant :

```text
# Secrets et état local
*.pem
*.key
.env
*.tfstate
*.tfstate.*
.terraform/
terraform.tfvars
credentials
kubeconfig
```

- Si une clé fuit : **IAM → l'utilisateur → Security credentials → Deactivate puis Delete** immédiatement, puis vérifie la facturation et CloudTrail.
- Préfère les **rôles IAM** dès que c'est possible (une instance EC2, un pipeline) : ils donnent des identifiants temporaires renouvelés automatiquement, sans clé stockée nulle part.
:::

## Étape 4 — Alertes de budget (obligatoire)

1. Console → **Billing and Cost Management → Budgets → Create budget**.
2. *Use a template* → **Zero spend budget** : tu reçois un e-mail dès que tu dépenses 0,01 $ au-delà de l'offre gratuite.
3. Crée un second budget **Monthly cost budget** de **20 $** (ou le montant que tu acceptes), avec alertes à 50 %, 80 % et 100 %.
4. **Billing → Billing preferences** → active *Receive Free Tier usage alerts* et les alertes de facturation CloudWatch.
5. Active **Cost Explorer** (gratuit) pour voir d'où viennent tes dépenses.

:::tip Le rituel de fin de session
À la fin de chaque séance de travail, ouvre **Billing → Bills** (ou Cost Explorer, regroupé par service) et la page **EC2 → Instances** de *chaque région que tu as utilisée*. Ça prend 1 minute et ça évite 99 % des mauvaises surprises. AWS affiche aussi une vue globale : **EC2 Global View**.
:::

## Étape 5 — Quelques réglages utiles

- **Région par défaut** : en haut à droite de la console, choisis *Europe (Paris) eu-west-3* et garde-la. Une ressource créée dans une autre région est **invisible** tant que tu ne changes pas de région dans la console : c'est la cause n°1 du « mais où est passée mon instance ? ».
- **CloudTrail** : activé par défaut pour 90 jours d'historique des actions (*Event history*). Utile pour savoir qui a fait quoi.
- **Tags** : prends l'habitude de taguer chaque ressource avec `Project=io-NN` et `Owner=<toi>`. Ça permet de filtrer les coûts par projet dans Cost Explorer.

# Maîtriser les coûts

Le parcours peut coûter **presque rien** ou **plusieurs centaines d'euros** : tout dépend de ta rigueur pour tout détruire à la fin de chaque séance.

## Ce qui coûte cher (même quand ça ne fait rien)

| Ressource | Coût approximatif | Remarque |
|---|---|---|
| **NAT Gateway** | ~0,05 $/h ≈ **35 $/mois** + données | Facturée à l'heure dès sa création. Projets 01, 02, 11, 22. |
| **Cluster EKS** (plan de contrôle) | 0,10 $/h ≈ **73 $/mois** | En plus des nœuds EC2. Projets 06, 08, 12, 15, 16, 19, 27, 28, 30. |
| **Load Balancer** (ALB/NLB) | ~0,025 $/h ≈ **18 $/mois** | Chaque `Service` Kubernetes de type `LoadBalancer` en crée un ! |
| **Transit Gateway** | ~0,05 $/h par attachement | Projets 01 et 02. Deux VPC = 2 attachements ≈ 73 $/mois. |
| **Instance t3.large / t2.large** | ~0,09 $/h ≈ **65 $/mois** | Jenkins + SonarQube en ont besoin (projets 09, 24, 25…). |
| **RDS Multi-AZ** | double du prix d'une instance simple | Projet 01 : fais du Single-AZ pour apprendre. |
| **Elastic IP non attachée** | ~0,005 $/h | Toute IPv4 publique est payante depuis 2024. |
| **Volumes EBS / snapshots** | ~0,09 $/Go/mois | Survivent à l'instance si « Delete on termination » est décoché. |
| **AKS / VM Azure** | variable | Azure facture aussi à l'heure. |

## Les bons réflexes

1. **Arrête** (*Stop*) les instances EC2 quand tu fais une pause d'une journée ; **détruis** (*Terminate*) tout à la fin d'un projet. Une instance arrêtée ne coûte plus en calcul, mais ses disques EBS et son IP élastique continuent de coûter.
2. Pour les projets en **Terraform**, `terraform destroy` est ton meilleur ami.
3. Pour **EKS**, supprime d'abord les `Service` de type `LoadBalancer` et les `Ingress` (sinon les Load Balancers restent orphelins et bloquent la suppression du VPC), puis `eksctl delete cluster`.
4. Travaille par **sessions concentrées** : monte l'infra, fais le projet, détruis. Si un projet prend plusieurs jours, écris l'infra en Terraform pour la recréer en 5 minutes le lendemain.
5. Utilise **AWS Nuke** ou la console *Resource Groups & Tag Editor* (recherche par tag `Project`) pour retrouver ce qui traîne.

:::danger Le scénario catastrophe classique
Tu crées un cluster EKS un vendredi pour le projet 08, ça marche, tu es content, tu fermes l'ordinateur. Tu reviens trois semaines plus tard : cluster (50 $) + 2 nœuds (40 $) + NAT Gateway (25 $) + 2 Load Balancers (27 $) ≈ **140 $**. Personne ne te préviendra, à part ton alerte de budget. D'où l'étape 4.
:::

# Les autres comptes à créer

| Service | Pour quoi | Quand |
|---|---|---|
| **GitHub** | Héberger le code, GitHub Actions | Maintenant |
| **Docker Hub** | Publier des images Docker | Projet 05 |
| **Azure** (`azure.microsoft.com/free`) | 200 $ de crédit sur 30 jours + services gratuits 12 mois | Projet 07 (ouvre-le juste avant, pour profiter des 30 jours) |
| **Azure DevOps** (`dev.azure.com`) | Pipelines, Repos, Boards | Projet 07 |
| **SonarCloud** (`sonarcloud.io`) | Analyse de qualité de code en ligne, gratuite pour les dépôts publics | Projet 01 |
| **JFrog** (offre gratuite / essai) | Dépôt d'artefacts Maven et Docker | Projet 01 / 06 |
| **GitLab** | GitLab CI | Projet 26 |
| **TMDB** (`themoviedb.org`) | Clé d'API pour les clones Netflix | Projet 09 |
| **NVD** (`nvd.nist.gov/developers/request-an-api-key`) | Clé d'API pour OWASP Dependency-Check | Projet 09 |

:::warn Une adresse e-mail, un mot de passe par service
Utilise un gestionnaire de mots de passe (Bitwarden, 1Password, KeePassXC) et active la double authentification partout où c'est possible. En DevOps, tes comptes donnent accès à de l'infrastructure qui coûte de l'argent.
:::
