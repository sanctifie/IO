#!/usr/bin/env bash
# Projet 03 — automatise les étapes 1 à 6 de l'exercice Linux (bible, projet 03).
# À lancer en root sur une instance Ubuntu JETABLE :  sudo ./setup.sh
# Les mots de passe sont lus dans la variable PASSWORD (défaut : un mot de passe aléatoire affiché à la fin).
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Lance ce script avec sudo"; exit 1; }
PASSWORD="${PASSWORD:-$(openssl rand -base64 12)}"

mkuser() { id "$1" >/dev/null 2>&1 || useradd -m -s /bin/bash "$1"; echo "$1:$PASSWORD" | chpasswd; }
as() { sudo -u "$1" bash -c "$2"; }   # exécuter une commande en tant qu'un autre utilisateur
# Dans l'exercice, chaque utilisateur tape son mot de passe à chaque sudo. Pour pouvoir scripter,
# on autorise temporairement sudo sans mot de passe, et on retire cette règle à la fin.
SUDOERS=/etc/sudoers.d/99-io03
echo "user1,user2,user4 ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS" && chmod 440 "$SUDOERS"
trap 'rm -f "$SUDOERS"' EXIT

echo "== Étape 1 : root =="
for u in user1 user2 user3; do mkuser "$u"; done
getent group devops >/dev/null || groupadd devops
getent group aws    >/dev/null || groupadd aws
usermod -g devops user2
usermod -g devops user3
usermod -aG aws user1
mkdir -p /dir1 /dir2/dir1/dir2/dir10 /dir4 /dir6 /dir7/dir10 /dir8 /opt/dir14/dir10
touch /dir1/f1 /f2
chown user1:devops /dir1 /dir7/dir10 /f2

echo "== Étape 2 : user1 (avec sudo) =="
usermod -aG sudo user1
as user1 "sudo useradd -m -s /bin/bash user4 2>/dev/null || true; sudo useradd -m -s /bin/bash user5 2>/dev/null || true"
echo "user4:$PASSWORD" | chpasswd; echo "user5:$PASSWORD" | chpasswd
as user1 "getent group app >/dev/null || sudo groupadd app; getent group database >/dev/null || sudo groupadd database"

echo "== Étape 3 : user4 =="
usermod -aG sudo user4
as user4 "sudo mkdir -p /dir6/dir4 && sudo touch /f3 && sudo mv /dir1/f1 /dir2/dir1/dir2/ && sudo mv /f2 /f4"

echo "== Étape 4 : user1 =="
as user1 'sudo mkdir -p /home/user2/dir1
cd /dir2/dir1/dir2/dir10 && sudo touch ../../../../opt/dir14/dir10/f1
sudo mv /opt/dir14/dir10/f1 ~/ && sudo chown user1: ~/f1
sudo rm -r /dir4
sudo find /opt/dir14 -mindepth 1 -delete
echo "Linux assessment for an DevOps Engineer!! Learn with Fun!!" | sudo tee /f3 > /dev/null'

echo "== Étape 5 : user2 =="
usermod -aG sudo user2
as user2 'sudo touch /dir1/f2
sudo rm -r /dir6 /dir8
sudo sed -i "s/DevOps/devops/g" /f3
line=$(head -n1 /f3); for i in $(seq 10); do echo "$line" | sudo tee -a /f3 > /dev/null; done   # équivalent de yy puis 10p dans vim
sudo sed -i "s/Engineer/engineer/g" /f3
echo "Lignes contenant engineer : $(grep -c engineer /f3)"
sudo rm /f3'

echo "== Étape 6 : root =="
touch /tmp/f3
echo "Fichiers nommés f3 :"; find / -name f3 -not -path "/proc/*" 2>/dev/null || true
echo "Éléments dans / : $(ls -A / | wc -l) (dont fichiers : $(find / -maxdepth 1 -type f | wc -l))"
echo "Dernière ligne de /etc/passwd : $(tail -n 1 /etc/passwd)"

echo
echo "Terminé. Mot de passe des utilisateurs user1..user5 : $PASSWORD"
echo "Étapes 7 et 8 (volume EBS) : ./mount-ebs.sh après avoir attaché le volume."
