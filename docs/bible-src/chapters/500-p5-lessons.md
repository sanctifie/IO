@@part Partie 5 | DevSecOps & Observabilité | Intégrer la sécurité à chaque étape du pipeline, et savoir en permanence ce qui se passe en production. Neuf projets : Netflix, Zomato, Swiggy en blue/green, .NET, Petshop, Reddit avec Argo CD, Chatbot, Voting App microservices et Blog App avec Nexus.

# Leçon 14 — DevSecOps : la sécurité dans le pipeline

## Le principe du « shift left »

Autrefois, la sécurité était vérifiée **à la fin**, juste avant la mise en production, par une équipe séparée. Découvrir une faille à ce moment-là coûte cher (il faut tout refaire) et bloque les livraisons. Le **DevSecOps** déplace les contrôles **vers la gauche** de la boucle DevOps : dans l'éditeur du développeur, dans la pull request, dans chaque exécution du pipeline. **Chaque commit est vérifié automatiquement.**

```ascii
 Code ──► Commit ──► Build ──► Tests ──► Image ──► Registre ──► Déploiement ──► Production
  │         │         │          │         │          │             │               │
 IDE      secrets   SAST       SCA      scan       scan          policy           DAST,
 lint     (gitleaks) (Sonar)   (OWASP   image      continu       (OPA/Kyverno)    runtime
                               DC,Trivy) (Trivy)   (ECR/ACR)                       (Falco), WAF
```

## Les familles de contrôles

| Sigle | Nom | Ce que ça vérifie | Outils du parcours |
|---|---|---|---|
| **SAST** | *Static Application Security Testing* | le **code source** : injections, mauvaises pratiques, secrets codés en dur | **SonarQube**, Semgrep, CodeQL |
| **SCA** | *Software Composition Analysis* | les **dépendances** (bibliothèques open source) : vulnérabilités connues (CVE), licences | **OWASP Dependency-Check**, **Trivy fs**, Snyk, Dependabot |
| **Scan d'image** | — | les paquets de l'**image Docker** (OS + runtime) | **Trivy image**, scan ECR/ACR, Grype |
| **IaC scanning** | — | les **fichiers d'infrastructure** : bucket public, port 22 ouvert, chiffrement absent | **Trivy config**, Checkov, tfsec, KICS |
| **Secret scanning** | — | les **secrets** commités par erreur | gitleaks, trufflehog, GitHub secret scanning |
| **DAST** | *Dynamic Application Security Testing* | l'**application en fonctionnement**, attaquée de l'extérieur | OWASP ZAP |
| **Runtime** | — | les comportements suspects **en production** | Falco, GuardDuty, WAF |

## Les vulnérabilités : CVE et CVSS

Une **CVE** (*Common Vulnerabilities and Exposures*) est l'identifiant public d'une faille connue, par exemple `CVE-2021-44228` (Log4Shell). Le score **CVSS** (de 0 à 10) mesure sa gravité : **LOW**, **MEDIUM**, **HIGH**, **CRITICAL**. Les scanners comparent les versions de tes paquets à des bases de CVE (la **NVD** américaine, les bases des distributions, GitHub Advisories).

:::why Pourquoi la plupart des failles viennent des dépendances
Une application moderne contient souvent **80 à 90 % de code open source** (bibliothèques npm, Maven, PyPI, paquets de l'image de base). Ton code est peut-être parfait, mais une vieille version de bibliothèque peut ouvrir la porte. D'où l'importance du SCA et du scan d'image, et de **mettre à jour régulièrement** (Dependabot, Renovate).
:::

## SonarQube

SonarQube analyse le code et classe les problèmes en **bugs**, **vulnérabilités**, **security hotspots** (code sensible à revoir à la main), **code smells** (maintenabilité), et mesure la **couverture de tests** et la **duplication**. La **Quality Gate** définit les conditions d'acceptation, surtout pour le **nouveau code** (« pas de nouvelle vulnérabilité, couverture ≥ 80 % sur le code ajouté »). Dans Jenkins :

```groovy
stage('Analyse SonarQube') {
    steps {
        withSonarQubeEnv('sonar-server') {           // nom du serveur déclaré dans Manage Jenkins > System
            sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=monapp -Dsonar.projectName=monapp"
        }
    }
}
stage('Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true   // true = le pipeline ÉCHOUE si la porte est rouge
        }
    }
}
```

:::warn `abortPipeline: false`
Beaucoup de projets du dépôt d'origine utilisent `waitForQualityGate abortPipeline: false` : le résultat est affiché, mais **le pipeline continue même si la Quality Gate échoue**. C'est utile pour démarrer sans tout bloquer, mais ce n'est **pas** du DevSecOps : un contrôle qui ne bloque jamais finit par être ignoré. Une fois le projet stabilisé, passe à `true`.
:::

## Trivy

**Trivy** (Aqua Security) est le couteau suisse du scan, open source et rapide :

```bash
trivy fs .                                        # dépendances et secrets du dossier (SCA)
trivy image monapp:1.0                            # paquets de l'image
trivy image --severity HIGH,CRITICAL --exit-code 1 monapp:1.0   # code retour 1 s'il y a du HIGH/CRITICAL → fait échouer le pipeline
trivy config ./terraform                          # erreurs de configuration IaC
trivy k8s --report summary cluster                # le cluster Kubernetes entier
trivy image --format template --template "@contrib/html.tpl" -o rapport.html monapp:1.0   # rapport HTML
```

Le dépôt d'origine redirige souvent la sortie dans un fichier (`trivy fs . > trivyfs.txt`) sans jamais faire échouer le build : là encore, c'est informatif. L'option `--exit-code 1` en fait un vrai contrôle.

## OWASP Dependency-Check

Outil de SCA de l'OWASP, très utilisé avec Jenkins (plugin *OWASP Dependency-Check*). Il télécharge la base **NVD** puis compare les dépendances du projet.

:::warn La clé d'API NVD
Depuis 2023, la NVD limite fortement les téléchargements anonymes : sans clé, la première exécution peut prendre **des heures** ou échouer (erreurs 403/429). Demande une clé gratuite (`https://nvd.nist.gov/developers/request-an-api-key`), range-la dans les credentials Jenkins (*Secret text*, ID `nvd-api-key`) et passe-la à l'outil :
```groovy
withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_KEY')]) {
    dependencyCheck additionalArguments: "--scan ./ --format XML --nvdApiKey ${NVD_KEY} --disableYarnAudit --disableNodeAudit",
                    odcInstallation: 'DP-Check'
}
dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
```
La base est mise en cache sur le serveur Jenkins : seules les exécutions suivantes sont rapides.
:::

## Les bonnes pratiques de sécurité à appliquer partout

- **Secrets** : jamais dans Git ni dans une image ; un coffre (Credentials, Secrets Manager, Key Vault) ; rotation ; détection automatique (gitleaks en pre-commit et en CI).
- **Images** : image de base minimale et à jour, utilisateur non-root, multi-stage, tag immuable, scan, signature (cosign).
- **Moindre privilège** partout : IAM, RBAC Kubernetes, Security Groups, jetons à portée limitée.
- **Pas de `chmod 777`**, pas de ports ouverts à `0.0.0.0/0` sans raison, pas de mots de passe par défaut (`admin/admin` de SonarQube, Grafana, Nexus…).
- **Mettre à jour** : OS, dépendances, images, outils (Jenkins et ses plugins sont des cibles fréquentes).

# Leçon 15 — Observabilité : monitoring, logs, alertes

## Les trois piliers

| Pilier | Question | Exemple | Outils |
|---|---|---|---|
| **Métriques** | « Combien ? À quelle vitesse ? » | CPU 85 %, 230 requêtes/s, 2 % d'erreurs, latence p95 = 300 ms | **Prometheus**, CloudWatch, Azure Monitor |
| **Logs** | « Que s'est-il passé exactement ? » | `ERROR Payment failed: card declined (order 4521)` | Loki, ELK/OpenSearch, CloudWatch Logs |
| **Traces** | « Où le temps a-t-il été passé dans cette requête ? » | front 20 ms → API 40 ms → base 350 ms | OpenTelemetry, Jaeger, Tempo, X-Ray |

Et par-dessus : **tableaux de bord** (Grafana) et **alertes** (Alertmanager, CloudWatch Alarms) qui préviennent un humain quand quelque chose ne va pas.

:::why Quoi surveiller ? Les « golden signals »
Google propose 4 signaux d'or pour tout service : **latence** (temps de réponse), **trafic** (requêtes par seconde), **erreurs** (taux de réponses en échec), **saturation** (à quel point la ressource est pleine : CPU, mémoire, disque, connexions). Pour l'infrastructure, la méthode **USE** : *Utilization, Saturation, Errors*. Commence toujours par là avant d'ajouter 200 graphiques.
:::

## Prometheus

**Prometheus** collecte des métriques en **interrogeant** (*scrape*) à intervalle régulier des points d'accès HTTP `/metrics` exposés par les applications ou par des **exporters**, et les stocke dans une base de séries temporelles.

```ascii
            ┌──────────────── Prometheus (:9090) ─────────────────┐
            │ toutes les 15 s : GET http://cible/metrics           │──► règles d'alerte ──► Alertmanager ──► e-mail/Slack
            └─────┬────────────────┬───────────────────┬───────────┘
                  ▼                ▼                   ▼
          node_exporter :9100  Jenkins /prometheus  blackbox_exporter :9115
          (CPU, RAM, disque     (jobs, builds,       (sonde HTTP : le site
           de la machine)        file d'attente)      répond-il ? en combien de temps ?)
                                                       ▲
                               Grafana (:3000) ── lit Prometheus ── tableaux de bord
```

```yaml
# /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: prometheus
    static_configs: [{ targets: ['localhost:9090'] }]
  - job_name: node_exporter
    static_configs: [{ targets: ['localhost:9100', '10.0.1.25:9100'] }]
  - job_name: jenkins
    metrics_path: /prometheus
    static_configs: [{ targets: ['10.0.1.10:8080'] }]
```

Le langage de requête **PromQL** :

```promql
up                                                          # 1 = cible joignable, 0 = en panne
100 - (avg by (instance)(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)   # % CPU utilisé
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100                # % mémoire libre
probe_success{job="blackbox"}                               # le site répond-il ?
```

L'installation complète (Prometheus, node_exporter, Grafana, blackbox_exporter en services systemd) est en **annexe A.7** ; sur Kubernetes, on utilise le chart **kube-prometheus-stack** (annexe A.10).

## Grafana

**Grafana** se connecte à des sources de données (Prometheus, Loki, CloudWatch…) et affiche des tableaux de bord. On importe des tableaux prêts à l'emploi depuis `grafana.com/grafana/dashboards` par leur **ID** :

| ID | Tableau |
|---|---|
| **1860** | Node Exporter Full (machine Linux) |
| **9964** | Jenkins: Performance and Health Overview |
| **7587** | Prometheus Blackbox Exporter |
| **15757** à **15762** | Kubernetes (Views / Global, Namespaces, Pods…) |

## Les alertes

Une bonne alerte est **actionnable** (quelqu'un doit faire quelque chose), **rare** (sinon on finit par l'ignorer : *alert fatigue*) et décrit le **symptôme** vu par l'utilisateur (« le site répond en plus de 2 s ») plutôt qu'une cause interne (« le CPU est à 80 % »).

```yaml
# règle Prometheus
groups:
- name: site
  rules:
  - alert: SiteDown
    expr: probe_success{job="blackbox"} == 0
    for: 2m                                   # doit durer 2 minutes avant de déclencher
    labels: { severity: critical }
    annotations:
      summary: "Le site {{ $labels.instance }} ne répond plus"
```

:::interview
- Différence entre SAST, SCA, DAST ? Donne un outil pour chacun.
- Que fais-tu si Trivy trouve une CVE CRITICAL dans ton image ? *(Mettre à jour l'image de base ou la dépendance, reconstruire ; si aucun correctif n'existe : évaluer l'exploitabilité, documenter une exception temporaire, compenser.)*
- Quels sont les trois piliers de l'observabilité ? Les 4 golden signals ?
- Prometheus fonctionne-t-il en push ou en pull ? Quels avantages ?
- Qu'est-ce qu'une bonne alerte ?
:::
