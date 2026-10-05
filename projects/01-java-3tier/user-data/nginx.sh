#!/bin/bash
# Projet 01 — user data du Launch Template Nginx. Remplacer BACKEND par le nom DNS du NLB interne.
set -euxo pipefail
BACKEND=REMPLACER-PAR-LE-DNS-DU-NLB-INTERNE
cat > /etc/nginx/conf.d/dptweb.conf <<CONF
server {
    listen 80 default_server;
    server_name _;
    location / {
        proxy_pass http://$BACKEND:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
CONF
# Libère le port 80 occupé par le "server" par défaut de nginx.conf (Amazon Linux)
sed -i 's/listen       80;/listen 8081;/; s/listen       \[::\]:80;/listen [::]:8081;/' /etc/nginx/nginx.conf
nginx -t && systemctl reload nginx
