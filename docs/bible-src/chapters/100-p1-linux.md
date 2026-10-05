@@part Partie 1 | Les fondamentaux | Linux, réseau et premiers services AWS. Trois leçons, puis trois projets : un TP Linux complet, une architecture réseau VPC haute disponibilité, et une application Java déployée sur une architecture 3-tiers.

# Leçon 1 — Linux pour le DevOps

Linux est le système d'exploitation de l'immense majorité des serveurs, des conteneurs Docker et des nœuds Kubernetes. Tu n'as pas besoin d'en être expert pour commencer, mais tu dois être à l'aise avec ce qui suit.

## Le terminal et le shell

Le **terminal** est la fenêtre où tu tapes du texte. Le **shell** est le programme qui interprète ce que tu tapes ; sur la plupart des serveurs, c'est **Bash**. L'invite de commande ressemble à ceci :

```text
ubuntu@ip-172-31-5-10:~$
│      │              │└─ $ = utilisateur normal  (# = root)
│      │              └── ~ = tu es dans ton dossier personnel
│      └───────────────── nom de la machine
└──────────────────────── ton nom d'utilisateur
```

Une commande a toujours la même forme : `commande -options arguments`. Par exemple `ls -l /etc` : la commande `ls` (lister), l'option `-l` (format long), l'argument `/etc` (le dossier à lister).

:::tip Les 5 réflexes qui font gagner des heures
- <kbd>Tab</kbd> complète automatiquement les noms de commandes et de fichiers. Appuie deux fois pour voir les possibilités.
- <kbd>↑</kbd> rappelle les commandes précédentes. <kbd>Ctrl</kbd>+<kbd>R</kbd> cherche dans l'historique.
- <kbd>Ctrl</kbd>+<kbd>C</kbd> interrompt la commande en cours. <kbd>Ctrl</kbd>+<kbd>L</kbd> efface l'écran.
- `man ls` affiche le manuel de `ls` (touche <kbd>q</kbd> pour quitter). `ls --help` donne un résumé.
- `history` liste les dernières commandes tapées.
:::

## L'arborescence des fichiers

Sous Linux, tout part de la **racine** `/`. Il n'y a pas de `C:\`.

| Dossier | Contenu |
|---|---|
| `/` | La racine de tout |
| `/home/<user>` | Les dossiers personnels des utilisateurs (`~` est un raccourci vers le tien) |
| `/root` | Le dossier personnel de l'utilisateur root |
| `/etc` | Les **fichiers de configuration** (`/etc/ssh/sshd_config`, `/etc/passwd`…) |
| `/var` | Les données variables : **logs** (`/var/log`), données de services (`/var/lib/jenkins`) |
| `/opt` | Les logiciels installés « à la main » (`/opt/maven`, `/opt/sonarqube`) |
| `/usr/bin`, `/usr/local/bin` | Les programmes exécutables |
| `/tmp` | Fichiers temporaires, effacés au redémarrage |
| `/dev` | Les périphériques (disques : `/dev/xvda`, `/dev/nvme1n1`) |
| `/proc` | Infos du noyau sur les processus et le système (fichiers virtuels) |
| `/mnt`, `/data` | Points de montage de disques supplémentaires |

**Chemin absolu** : commence par `/` (`/etc/nginx/nginx.conf`), valable de n'importe où. **Chemin relatif** : part du dossier courant (`nginx/nginx.conf`). `.` désigne le dossier courant, `..` le dossier parent.

## Naviguer et manipuler les fichiers

```bash
pwd                      # où suis-je ? (print working directory)
ls -la                   # lister, y compris fichiers cachés (commençant par .)
cd /var/log              # aller dans /var/log
cd ..                    # remonter d'un niveau
cd ~   (ou juste cd)     # revenir à son dossier personnel
cd -                     # revenir au dossier précédent

mkdir projet             # créer un dossier
mkdir -p a/b/c           # créer toute l'arborescence d'un coup
touch notes.txt          # créer un fichier vide (ou mettre à jour sa date)
cp notes.txt copie.txt   # copier
cp -r dossier/ sauv/     # copier un dossier (récursif)
mv copie.txt ancien.txt  # déplacer OU renommer
rm ancien.txt            # supprimer un fichier (pas de corbeille !)
rm -r dossier/           # supprimer un dossier et son contenu
rmdir dossier_vide       # supprimer un dossier vide
```

:::danger `rm -rf` ne pardonne pas
Il n'y a **pas de corbeille** sous Linux. `rm -rf /` (en root) efface tout le système. Relis toujours une commande `rm -r` avant d'appuyer sur Entrée, surtout si elle contient une variable (`rm -rf $DOSSIER/` avec une variable vide devient `rm -rf /`).
:::

## Lire et écrire dans les fichiers

```bash
cat fichier              # afficher tout le fichier
less fichier             # afficher page par page (q pour quitter, / pour chercher)
head -n 20 fichier       # 20 premières lignes
tail -n 20 fichier       # 20 dernières lignes
tail -f /var/log/syslog  # suivre un fichier en direct (logs !) — Ctrl+C pour arrêter
wc -l fichier            # compter les lignes

echo "bonjour" > f.txt   # écrire dans f.txt (ÉCRASE le contenu)
echo "suite" >> f.txt    # ajouter à la fin de f.txt
```

**Les éditeurs** : `nano fichier` est le plus simple (les raccourcis sont affichés en bas, <kbd>Ctrl</kbd>+<kbd>O</kbd> pour enregistrer, <kbd>Ctrl</kbd>+<kbd>X</kbd> pour quitter). `vim` est partout et très puissant, mais déroutant au début :

| Dans vim | Action |
|---|---|
| `i` | passer en mode insertion (pour taper du texte) |
| <kbd>Échap</kbd> | revenir en mode normal |
| `:w` / `:q` / `:wq` / `:q!` | enregistrer / quitter / les deux / quitter sans enregistrer |
| `yy` puis `p` | copier la ligne, la coller en dessous |
| `10p` | coller 10 fois |
| `dd` | supprimer la ligne |
| `/mot` puis `n` | chercher « mot », occurrence suivante |
| `:%s/ancien/nouveau/g` | remplacer partout dans le fichier |
| `u` | annuler |

## Chercher et filtrer

```bash
grep "error" app.log            # lignes contenant "error"
grep -i "error" app.log         # sans tenir compte des majuscules
grep -r "password" /etc/        # chercher récursivement dans un dossier
grep -v "DEBUG" app.log         # lignes NE contenant PAS DEBUG

find / -name "f3" 2>/dev/null   # trouver tous les fichiers nommés f3
find /var/log -name "*.log" -mtime -1   # fichiers .log modifiés il y a moins d'un jour

sed -i 's/DevOps/devops/g' f3   # remplacer dans un fichier sans l'ouvrir
```

**Le pipe `|`** envoie la sortie d'une commande à l'entrée de la suivante. C'est la philosophie Unix : de petits outils qu'on assemble.

```bash
cat /var/log/auth.log | grep "Failed password" | wc -l   # combien de tentatives SSH échouées ?
ps aux | grep java                                       # les processus java
ls / | wc -l                                             # combien d'éléments dans / ?
```

`2>/dev/null` redirige les messages d'erreur (le flux n°2) vers le « trou noir » `/dev/null`. Pratique avec `find`, qui se plaint de chaque dossier qu'il n'a pas le droit de lire.

## Utilisateurs et groupes

Linux est **multi-utilisateur**. Chaque fichier appartient à un **utilisateur** et à un **groupe**. Chaque utilisateur a un **groupe principal** et peut appartenir à des **groupes secondaires**.

```bash
whoami                         # qui suis-je ?
id                             # mon UID, mon groupe principal, mes groupes
sudo useradd -m -s /bin/bash user1   # créer user1 avec un dossier personnel et bash
sudo passwd user1              # lui définir un mot de passe
sudo groupadd devops           # créer un groupe
sudo usermod -g devops user2   # changer le groupe PRINCIPAL de user2
sudo usermod -aG aws user1     # AJOUTER user1 au groupe secondaire aws (-a est vital !)
sudo userdel -r user5          # supprimer un utilisateur et son dossier
su - user1                     # devenir user1 (demande SON mot de passe)
sudo -i                        # devenir root
exit                           # revenir à l'utilisateur précédent
```

Les comptes sont listés dans `/etc/passwd`, les groupes dans `/etc/group`, les mots de passe (chiffrés) dans `/etc/shadow`.

:::warn L'oubli du `-a`
`usermod -G docker bob` **remplace** tous les groupes secondaires de bob par `docker`. `usermod -aG docker bob` les **complète**. Oublier le `-a` peut retirer un utilisateur du groupe `sudo`… et te verrouiller hors de ta propre machine.
:::

**sudo** : un utilisateur peut exécuter des commandes en tant que root s'il est dans le groupe `sudo` (Ubuntu) ou `wheel` (Amazon Linux/RHEL), ou s'il est autorisé dans `/etc/sudoers`. Modifie ce fichier uniquement avec `sudo visudo`, qui vérifie la syntaxe avant d'enregistrer.

## Les permissions

```text
$ ls -l script.sh
-rwxr-x---  1  alice  devops  1024  oct 4 10:00  script.sh
│└┬┘└┬┘└┬┘     └─┬─┘  └─┬──┘
│ │  │  │        │      └── groupe propriétaire
│ │  │  │        └───────── utilisateur propriétaire
│ │  │  └── droits des AUTRES      : --- (rien)
│ │  └───── droits du GROUPE       : r-x (lire, exécuter)
│ └──────── droits du PROPRIÉTAIRE : rwx (lire, écrire, exécuter)
└────────── type : - fichier, d dossier, l lien
```

| Droit | Sur un fichier | Sur un dossier | Valeur |
|---|---|---|---|
| `r` | lire le contenu | lister le contenu | 4 |
| `w` | modifier | créer/supprimer des fichiers dedans | 2 |
| `x` | exécuter | entrer dedans (`cd`) | 1 |

On additionne les valeurs : `rwx` = 7, `r-x` = 5, `r--` = 4. Donc `chmod 750` = `rwxr-x---`.

```bash
chmod 755 script.sh          # rwxr-xr-x
chmod +x script.sh           # ajouter le droit d'exécution
chmod 400 ma-cle.pem         # lecture seule pour moi : OBLIGATOIRE pour une clé SSH
sudo chown user1 /dir1       # changer le propriétaire
sudo chown user1:devops /f2  # changer propriétaire et groupe
sudo chgrp devops /dir1      # changer seulement le groupe
sudo chown -R jenkins:jenkins /var/lib/jenkins   # récursif
```

:::danger `chmod 777`
Tu verras souvent `chmod 777` dans des tutoriels (y compris certains projets du dépôt d'origine, par exemple sur `/var/run/docker.sock`). Ça donne **tous les droits à tout le monde** : c'est une faille de sécurité. La bonne solution est presque toujours d'ajouter l'utilisateur au bon groupe (`usermod -aG docker jenkins`) puis de redémarrer le service ou la session.
:::

## Les paquets

| Distribution | Gestionnaire | Installer | Mettre à jour |
|---|---|---|---|
| Ubuntu / Debian | `apt` | `sudo apt install nginx` | `sudo apt update && sudo apt upgrade` |
| Amazon Linux 2023 / RHEL / Fedora | `dnf` | `sudo dnf install nginx` | `sudo dnf upgrade` |
| Amazon Linux 2 / CentOS 7 (anciens) | `yum` | `sudo yum install nginx` | `sudo yum update` |

`apt update` rafraîchit la **liste** des paquets disponibles ; `apt upgrade` installe les **mises à jour**. Pour installer un logiciel absent des dépôts officiels (Jenkins, Docker, Terraform…), on ajoute le dépôt de l'éditeur avec sa clé GPG (qui garantit que les paquets viennent bien de lui), comme tu l'as fait pour Terraform.

## Processus et services

```bash
ps aux                       # tous les processus
top   (ou htop)              # moniteur en temps réel (q pour quitter)
kill 1234                    # demander au processus 1234 de s'arrêter
kill -9 1234                 # le tuer de force (dernier recours)

sudo systemctl status nginx  # état du service
sudo systemctl start nginx   # démarrer
sudo systemctl stop nginx    # arrêter
sudo systemctl restart nginx # redémarrer
sudo systemctl enable nginx  # démarrer automatiquement au boot
sudo systemctl enable --now nginx   # les deux à la fois
sudo journalctl -u nginx -f  # suivre les logs du service
sudo systemctl daemon-reload # après avoir créé/modifié un fichier .service
```

**systemd** est le gestionnaire de services de Linux. Un service est décrit par un fichier *unit* dans `/etc/systemd/system/`. Tu en écriras plusieurs (Tomcat, Prometheus, SonarQube). Voici un modèle commenté :

```ini
# /etc/systemd/system/monapp.service
[Unit]
Description=Mon application
After=network.target          # démarrer après le réseau

[Service]
User=monapp                   # ne JAMAIS faire tourner une app en root si on peut l'éviter
ExecStart=/opt/monapp/bin/start.sh
Restart=on-failure            # redémarrer automatiquement en cas de crash
Environment=JAVA_HOME=/usr/lib/jvm/java-17

[Install]
WantedBy=multi-user.target    # activé au démarrage normal du système
```

## Disques et systèmes de fichiers

```bash
df -h                        # espace utilisé par système de fichiers (h = lisible)
du -sh /var/log              # taille d'un dossier
lsblk                        # les disques et partitions
free -h                      # mémoire vive
```

Pour utiliser un nouveau disque, il faut : **1)** le formater (créer un système de fichiers), **2)** le monter dans un dossier, **3)** rendre le montage permanent dans `/etc/fstab`. Tu le feras concrètement dans le projet 03.

## Réseau (côté machine)

```bash
ip a                         # mes adresses IP
ss -tlnp                     # quels ports sont en écoute et par quel programme
curl -I http://localhost:8080   # tester un service web (en-têtes seulement)
ping 8.8.8.8                 # la machine joint-elle Internet ?
nslookup google.com  (ou dig)   # résolution DNS
ssh -i cle.pem ubuntu@1.2.3.4   # se connecter à une machine distante
scp -i cle.pem fichier ubuntu@1.2.3.4:/tmp/   # copier un fichier vers elle
```

## Variables d'environnement et scripts

```bash
echo $HOME                   # afficher une variable
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64   # définir pour la session
echo 'export PATH=$PATH:/opt/maven/bin' >> ~/.bashrc  # rendre permanent
source ~/.bashrc             # recharger sans se reconnecter
```

`PATH` est la liste des dossiers où le shell cherche les commandes. Si tu installes Maven dans `/opt/maven` et que `mvn` est « command not found », c'est que `/opt/maven/bin` n'est pas dans le `PATH`.

Un **script Bash** est un fichier texte contenant des commandes :

```bash
#!/bin/bash
# sauvegarde.sh — archive les logs du jour vers S3
set -euo pipefail                 # s'arrêter à la première erreur (bonne pratique)

DATE=$(date +%F)                  # ex : 2026-10-04
ARCHIVE="/tmp/logs-$DATE.tar.gz"

tar -czf "$ARCHIVE" /var/log/monapp/
aws s3 cp "$ARCHIVE" "s3://mon-bucket-logs/$DATE/"
echo "Sauvegarde $DATE terminée"
```

```bash
chmod +x sauvegarde.sh && ./sauvegarde.sh
```

**cron** exécute des tâches planifiées. `crontab -e` ouvre ta table de tâches :

```text
# ┌ minute (0-59)  ┌ heure (0-23)  ┌ jour du mois  ┌ mois  ┌ jour de semaine (0=dimanche)
# │                │               │               │       │
  0                2               *               *       *     /opt/scripts/sauvegarde.sh
# => tous les jours à 2h00
```

:::exo Avant de passer au projet 03
Sur ta machine (WSL), sans regarder les réponses ci-dessus :
1. Crée l'arborescence `~/labo/a/b/c` en une commande.
2. Écris trois lignes dans `~/labo/notes.txt`, puis affiche seulement la dernière.
3. Rends un script exécutable uniquement par toi (`700`).
4. Trouve combien de lignes de `/etc/passwd` contiennent `nologin`.
5. Affiche les ports en écoute sur ta machine.
:::

# Leçon 2 — Le réseau, sans douleur

Le réseau est la compétence qui sépare le plus nettement les débutants des ingénieurs confirmés. 80 % des « ça ne marche pas » en cloud sont des problèmes réseau. Voici l'essentiel.

## Adresses IP

Une **adresse IPv4** identifie une machine sur un réseau : quatre nombres de 0 à 255, par exemple `192.168.1.10`. Chaque nombre fait 8 bits, donc une adresse fait 32 bits.

Certaines plages sont **privées** (utilisables uniquement à l'intérieur d'un réseau, jamais routées sur Internet) :

| Plage privée | Notation CIDR |
|---|---|
| 10.0.0.0 – 10.255.255.255 | `10.0.0.0/8` |
| 172.16.0.0 – 172.31.255.255 | `172.16.0.0/12` |
| 192.168.0.0 – 192.168.255.255 | `192.168.0.0/16` |

Toutes les autres adresses sont **publiques**, joignables depuis Internet.

## La notation CIDR (le `/16`, `/24`…)

`172.32.0.0/16` signifie : « les **16 premiers bits** sont fixes, le reste est libre ». Il reste 32 − 16 = 16 bits libres, soit 2¹⁶ = **65 536 adresses**.

| CIDR | Bits libres | Nombre d'adresses | Exemple |
|---|---|---|---|
| `/16` | 16 | 65 536 | un VPC entier : `172.32.0.0/16` |
| `/20` | 12 | 4 096 | un gros sous-réseau |
| `/24` | 8 | 256 | un sous-réseau : `172.32.1.0/24` = de 172.32.1.0 à 172.32.1.255 |
| `/28` | 4 | 16 | un tout petit sous-réseau |
| `/32` | 0 | 1 | une seule adresse : `82.64.10.5/32` (« seulement mon IP ») |
| `/0` | 32 | toutes | `0.0.0.0/0` = **tout Internet** |

:::tip La règle simple
Plus le nombre après le `/` est **petit**, plus le réseau est **grand**. Pour les `/16`, `/24`, `/32`, il suffit de compter : `/8` fixe le premier nombre, `/16` les deux premiers, `/24` les trois premiers, `/32` les quatre.
:::

AWS réserve **5 adresses** dans chaque sous-réseau (la première, les trois suivantes et la dernière). Un `/24` donne donc 251 adresses utilisables.

## Ports et protocoles

Une IP désigne une machine ; un **port** désigne un service sur cette machine. C'est comme l'adresse d'un immeuble (IP) et le numéro d'appartement (port).

| Port | Service |
|---|---|
| 22 | SSH |
| 80 / 443 | HTTP / HTTPS |
| 3306 | MySQL |
| 5432 | PostgreSQL |
| 8080 | Jenkins, Tomcat (convention) |
| 9000 | SonarQube |
| 8081 | Nexus |
| 9090 / 3000 | Prometheus / Grafana |
| 6443 | API Kubernetes |
| 30000–32767 | Kubernetes NodePort |

**TCP** garantit que les données arrivent complètes et dans l'ordre (web, SSH, bases de données). **UDP** est plus léger mais sans garantie (DNS, streaming).

## DNS

Le **DNS** traduit un nom (`www.exemple.com`) en adresse IP. Types d'enregistrements utiles :

| Type | Rôle | Exemple |
|---|---|---|
| **A** | nom → adresse IPv4 | `app.exemple.com → 13.37.1.2` |
| **CNAME** | nom → autre nom | `www.exemple.com → mon-lb-123.elb.amazonaws.com` |
| **Alias** (AWS) | comme CNAME, mais utilisable à la racine du domaine et gratuit | `exemple.com → ALB` |
| **TXT** | texte libre (vérifications) | validation de certificat |

## HTTP en 30 secondes

Le navigateur envoie une **requête** (`GET /login HTTP/1.1`), le serveur répond avec un **code de statut** :

| Code | Signification | Ce que ça t'apprend |
|---|---|---|
| 200 | OK | tout va bien |
| 301/302 | redirection | |
| 403 | interdit | droits / authentification |
| 404 | introuvable | mauvaise URL ou appli non déployée au bon endroit |
| 500 | erreur serveur | l'application a planté : regarde ses logs |
| 502/503/504 | mauvaise passerelle / indisponible / délai dépassé | le proxy ou le load balancer n'arrive pas à joindre l'application derrière lui |

## Les briques d'un réseau

- **Routeur** : fait passer les paquets d'un réseau à un autre, selon une **table de routage** (« pour aller vers X, passe par Y »).
- **Passerelle par défaut** : la route utilisée quand aucune autre ne correspond (`0.0.0.0/0`).
- **NAT** (*Network Address Translation*) : permet à des machines en IP privée de **sortir** sur Internet en partageant une IP publique, sans être **joignables** depuis Internet. C'est le rôle de ta box Internet chez toi.
- **Pare-feu** : autorise ou bloque le trafic selon des règles (IP source, port, protocole).
- **Load balancer** (répartiteur de charge) : reçoit le trafic et le répartit entre plusieurs serveurs ; retire automatiquement les serveurs en panne.
- **Reverse proxy** : un serveur (Nginx…) qui reçoit les requêtes et les transmet à une application derrière lui.
- **Bastion** (*jump host*) : une machine exposée à Internet uniquement en SSH, qui sert de point d'entrée unique pour administrer les machines privées.

:::analogy La résidence fermée
Un **VPC**, c'est une résidence privée. Les **sous-réseaux publics** sont les bâtiments en bordure de rue, avec une porte sur la rue (l'**Internet Gateway**). Les **sous-réseaux privés** sont les bâtiments au fond du parc : on ne peut pas y entrer depuis la rue, mais leurs habitants peuvent sortir faire des courses en passant par la loge du gardien (la **NAT Gateway**), qui note l'aller pour laisser passer le retour. Le **bastion** est le gardien, seul autorisé à faire entrer les visiteurs. Les **Security Groups** sont les serrures de chaque appartement.
:::

:::exo Teste-toi
1. Combien d'adresses dans `10.0.0.0/20` ? *(4 096)*
2. `172.32.1.0/24` et `172.32.2.0/24` se chevauchent-ils ? *(Non)*
3. Que signifie une règle de pare-feu « port 22, source `0.0.0.0/0` » ? *(SSH ouvert à tout Internet)*
4. Un navigateur renvoie 502 Bad Gateway derrière un load balancer. Où chercher en premier ? *(L'application derrière : tourne-t-elle, sur le bon port, le Security Group autorise-t-il le load balancer ?)*
:::
