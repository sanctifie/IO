# Scripts communs

Scripts d'installation réutilisés par plusieurs projets (bible : annexe A). Tous visent **Ubuntu 24.04**.

| Script | Rôle | Projets |
|---|---|---|
| `install-cli-tools.sh` | AWS CLI, Terraform, kubectl, eksctl, Helm (ton poste / serveur d'admin) | presque tous |
| `install-docker.sh` | Docker + Compose (dépôt officiel) | 05, 06, 09, 13, 16, 18, 24, 25, 27–30 |
| `install-jenkins.sh` | Java 21 + Jenkins LTS | 05, 06, 09, 13, 16, 18, 19, 24, 25, 27, 28, 30 |
| `install-trivy.sh` | Trivy | 09, 13, 16, 19, 23–25, 27, 28, 30 |
| `run-sonarqube.sh` | SonarQube en conteneur | 09, 13, 16, 18, 23–25, 27, 28, 30 |
| `run-nexus.sh` | Nexus en conteneur | 30 |
| `install-k8s-node.sh` + `k8s-init-master.sh` | cluster kubeadm | 09, 24, 25 |
| `install-monitoring.sh` + `prometheus.yml` | Prometheus, node_exporter, Blackbox, Grafana | 09, 13, 30 |

```bash
chmod +x common/*.sh
./common/install-docker.sh
```

Lis toujours un script avant de l'exécuter.
