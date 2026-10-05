@@part Partie 0 | Avant de commencer | Comprendre ce qu'est le DevOps et le cloud, préparer ton poste de travail, ouvrir et sécuriser tes comptes, et apprendre à ne jamais recevoir de mauvaise surprise sur ta facture.

# Le DevOps, c'est quoi ?

## Le problème que le DevOps résout

Imagine une entreprise des années 2005. D'un côté, les **développeurs** (*Dev*) écrivent le code des applications. Leur objectif : livrer de nouvelles fonctionnalités, vite. De l'autre, les **opérationnels** (*Ops*, les administrateurs système) font tourner les serveurs. Leur objectif : que rien ne tombe en panne. Donc changer le moins possible.

Les deux équipes ont des objectifs opposés. Le résultat :

- les développeurs « jettent le code par-dessus le mur » une fois tous les 6 mois ;
- la mise en production se fait un samedi soir, à la main, avec un document Word de 40 pages ;
- quelque chose casse, chacun accuse l'autre (« ça marche sur ma machine ! ») ;
- on corrige dans l'urgence, et on attend encore 6 mois avant la prochaine livraison.

Le **DevOps** est né vers 2009 pour casser ce mur. Ce n'est **ni un outil, ni un poste, ni une équipe** au départ : c'est une **culture** et un ensemble de **pratiques** pour que développement et exploitation travaillent ensemble, et pour livrer du logiciel **souvent, rapidement et de façon fiable**.

:::analogy La cuisine d'un restaurant
Avant le DevOps, c'est un restaurant où les cuisiniers inventent des plats sans jamais parler aux serveurs, et où les serveurs refusent tout nouveau plat de peur de se tromper. Le DevOps, c'est une brigade où tout le monde suit les mêmes fiches recettes (*le code*), où chaque plat est goûté avant de sortir (*les tests automatiques*), où le passe-plat est organisé et rapide (*le pipeline CI/CD*) et où on regarde en permanence si les clients finissent leur assiette (*le monitoring*).
:::

## Les piliers : le modèle CALMS

| Lettre | Pilier | Ce que ça veut dire concrètement |
|---|---|---|
| **C** | *Culture* | Responsabilité partagée : « you build it, you run it ». Pas de chasse au coupable après un incident (*post-mortem blameless*). |
| **A** | *Automation* | Tout ce qui est répétitif est automatisé : tests, build, déploiement, création de serveurs. |
| **L** | *Lean* | Livrer par petits morceaux, souvent. Éliminer les temps d'attente et le travail inutile. |
| **M** | *Measurement* | Mesurer pour décider : temps de déploiement, taux d'erreurs, temps de rétablissement. |
| **S** | *Sharing* | Partager le savoir, les outils, la documentation, les tableaux de bord. |

## La boucle DevOps

```ascii
          ┌────────── DEV ──────────┐   ┌────────── OPS ──────────┐
          │                         │   │                         │
   PLAN ──► CODE ──► BUILD ──► TEST ──► RELEASE ──► DEPLOY ──► OPERATE ──► MONITOR
     ▲                                                                       │
     └───────────────────── retours des utilisateurs et des métriques ◄──────┘
```

Chaque étape de la boucle a ses outils. Tu vas tous les utiliser dans ce parcours :

| Étape | Rôle | Outils du parcours |
|---|---|---|
| Plan | Organiser le travail | Azure Boards, GitHub Issues |
| Code | Écrire et versionner le code | **Git**, GitHub, GitLab, Azure Repos |
| Build | Compiler, empaqueter | Maven, Gradle, npm, **Docker** |
| Test | Vérifier la qualité et la sécurité | JUnit, **SonarQube**, **Trivy**, OWASP Dependency-Check |
| Release | Stocker les livrables versionnés | JFrog Artifactory, **Nexus**, Docker Hub, ECR, ACR |
| Deploy | Mettre en production | **Jenkins**, **GitHub Actions**, GitLab CI, Azure Pipelines, AWS CodePipeline, **Argo CD**, **Helm** |
| Operate | Faire tourner l'infrastructure | **AWS**, **Azure**, **Kubernetes**, **Terraform**, **Ansible** |
| Monitor | Observer et alerter | **Prometheus**, **Grafana**, CloudWatch, Application Insights |

## Les grandes notions que tu vas croiser partout

**Intégration continue (CI, *Continuous Integration*).** À chaque fois qu'un développeur pousse du code, un robot récupère le code, le compile et lance les tests automatiquement. Si quelque chose casse, on le sait en quelques minutes, pas en quelques mois.

**Livraison / déploiement continu (CD, *Continuous Delivery / Deployment*).** Le code qui a passé la CI est automatiquement empaqueté et prêt à être déployé (*delivery*), voire déployé automatiquement en production (*deployment*).

**Infrastructure as Code (IaC).** Au lieu de cliquer dans une console pour créer des serveurs, on **décrit l'infrastructure dans des fichiers texte** (Terraform, CloudFormation). Ces fichiers sont versionnés dans Git, relus, testés et rejoués à l'identique. C'est la fin du serveur « que seul Jean-Michel sait reconfigurer ».

**Conteneurs.** Une application empaquetée avec *tout* ce dont elle a besoin (bibliothèques, configuration) dans une « boîte » standard (Docker) qui tourne pareil partout : sur ton portable, en test, en production.

**Orchestration.** Quand on a des centaines de conteneurs, il faut un chef d'orchestre qui les place sur des machines, les redémarre s'ils plantent et les multiplie quand le trafic augmente : **Kubernetes**.

**GitOps.** Git devient la seule source de vérité : l'état voulu du système est dans Git, et un outil (Argo CD) s'assure en permanence que la réalité correspond à Git.

**DevSecOps.** On intègre la sécurité **dans** le pipeline (analyse du code, des dépendances, des images) au lieu de la vérifier à la fin. C'est ce qu'on appelle le *shift left* : déplacer les contrôles vers la gauche de la boucle, donc plus tôt.

**Observabilité.** Pouvoir répondre à « que se passe-t-il dans mon système en ce moment, et pourquoi ? » grâce aux **métriques**, aux **logs** et aux **traces**.

## Le métier d'ingénieur DevOps / Cloud

Dans la vraie vie, « DevOps » est devenu un intitulé de poste. Un ingénieur DevOps ou Cloud passe ses journées à :

- construire et maintenir des **pipelines CI/CD** ;
- écrire de l'**Infrastructure as Code** (Terraform surtout) ;
- gérer des **clusters Kubernetes** et des services cloud ;
- automatiser (scripts Bash/Python, Ansible) ;
- mettre en place **monitoring et alertes**, et intervenir sur les incidents ;
- sécuriser l'ensemble (droits IAM, secrets, scans) ;
- aider les développeurs à livrer plus vite (*platform engineering*).

:::info Les mesures DORA
Les équipes DevOps sont souvent évaluées avec 4 indicateurs, issus des recherches DORA (*DevOps Research and Assessment*) :
1. **Fréquence de déploiement** : combien de fois on livre en production.
2. **Délai de mise en production** (*lead time*) : temps entre un commit et sa mise en production.
3. **Taux d'échec des changements** : pourcentage de déploiements qui causent un incident.
4. **Temps de rétablissement** (*MTTR*) : temps pour réparer après un incident.

Les meilleures équipes déploient plusieurs fois par jour, en moins d'une heure, avec peu d'échecs, et réparent en moins d'une heure. Tout le parcours sert à acquérir les compétences qui permettent ça.
:::

:::interview
- Qu'est-ce que le DevOps, en une phrase ? *Une culture et des pratiques qui rapprochent développement et exploitation pour livrer souvent, vite et de façon fiable, grâce à l'automatisation et à la mesure.*
- Quelle différence entre *continuous delivery* et *continuous deployment* ? *En delivery, le déploiement en production reste déclenché par un humain. En deployment, il est automatique dès que tous les tests passent.*
- Qu'est-ce que l'Infrastructure as Code et pourquoi l'utiliser ? *Décrire l'infrastructure dans des fichiers versionnés. Bénéfices : reproductibilité, relecture, historique, rapidité, moins d'erreurs humaines.*
:::

# Le cloud, c'est quoi ?

## L'idée

Le **cloud computing**, c'est **louer** des ressources informatiques (serveurs, stockage, bases de données, réseau…) à la demande, via Internet, et **payer à l'usage**, au lieu d'acheter et d'installer ses propres serveurs.

:::analogy L'électricité
Au XIXᵉ siècle, chaque usine avait son propre générateur. Puis on s'est branché sur le réseau électrique : on paie ce qu'on consomme, sans s'occuper de la centrale. Le cloud fait la même chose pour l'informatique. AWS, Azure et Google Cloud sont les « centrales ».
:::

Les avantages :

- **Élasticité** : on passe de 2 à 200 serveurs en quelques minutes, puis on redescend.
- **Paiement à l'usage** : pas d'investissement de départ. *Attention : ça veut aussi dire qu'une ressource oubliée coûte de l'argent en continu.*
- **Services managés** : base de données, file de messages, Kubernetes… le fournisseur gère les mises à jour et la haute disponibilité.
- **Portée mondiale** : des datacenters sur tous les continents.

## IaaS, PaaS, SaaS : qui gère quoi ?

| Modèle | On loue… | Tu gères | Exemples |
|---|---|---|---|
| **On-premise** | rien (tu possèdes tout) | tout, du bâtiment à l'application | ton propre datacenter |
| **IaaS** (*Infrastructure as a Service*) | des machines virtuelles, du réseau, du stockage | l'OS, les mises à jour, le runtime, l'application | AWS EC2, Azure VM |
| **PaaS** (*Platform as a Service*) | une plateforme prête à exécuter ton code | ton code et sa configuration | AWS Elastic Beanstalk, Azure App Service, AWS Lambda |
| **SaaS** (*Software as a Service*) | un logiciel fini | tes données et tes utilisateurs | Gmail, GitHub, Slack |

Plus on monte, moins on a de travail d'administration, mais moins on a de contrôle.

## Régions et zones de disponibilité

Les fournisseurs découpent le monde en **régions** (par exemple `eu-west-3` = Paris, `eu-west-1` = Irlande, `us-east-1` = Virginie). Chaque région contient plusieurs **zones de disponibilité** (*Availability Zones*, AZ), comme `eu-west-3a`, `eu-west-3b`, `eu-west-3c` : ce sont des datacenters physiquement séparés (alimentation, réseau, refroidissement indépendants) mais reliés par des liaisons très rapides.

```ascii
 Région eu-west-3 (Paris)
 ┌────────────────────────────────────────────────────────────┐
 │  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐    │
 │  │  AZ  3a      │   │  AZ  3b      │   │  AZ  3c      │    │
 │  │ (datacenter) │◄─►│ (datacenter) │◄─►│ (datacenter) │    │
 │  └──────────────┘   └──────────────┘   └──────────────┘    │
 └────────────────────────────────────────────────────────────┘
```

:::why Pourquoi c'est important
Si tu mets tous tes serveurs dans une seule AZ et que ce datacenter a un problème (incendie, coupure), ton application tombe. **La haute disponibilité commence par répartir les serveurs sur au moins 2 AZ.** C'est exactement ce que demandent les projets 01 et 02.
:::

## Le modèle de responsabilité partagée

Le fournisseur sécurise **le cloud lui-même** (bâtiments, matériel, hyperviseur, réseau mondial). **Toi**, tu sécurises **ce que tu mets dans le cloud** : tes comptes et droits d'accès (IAM), tes données, la configuration de tes pare-feux, les mises à jour de tes systèmes, tes secrets.

:::danger La cause n°1 des incidents cloud
Ce ne sont pas des pirates de génie, ce sont des **erreurs de configuration** : un bucket S3 laissé public, une clé d'accès AWS publiée par erreur sur GitHub, un port de base de données ouvert à tout Internet, un compte root sans double authentification. Les robots scannent GitHub en permanence : **une clé AWS publiée est exploitée en quelques minutes** (souvent pour miner de la cryptomonnaie à tes frais).
:::

## AWS, Azure, Google Cloud

Le parcours utilise surtout **AWS** (le leader du marché) et un peu **Azure**. Les concepts sont les mêmes partout, seuls les noms changent :

| Concept | AWS | Azure | Google Cloud |
|---|---|---|---|
| Machine virtuelle | EC2 | Virtual Machines | Compute Engine |
| Réseau privé | VPC | VNet | VPC |
| Stockage d'objets | S3 | Blob Storage | Cloud Storage |
| Base SQL managée | RDS / Aurora | Azure SQL / Database for MySQL | Cloud SQL |
| Kubernetes managé | EKS | AKS | GKE |
| Registre d'images | ECR | ACR | Artifact Registry |
| Fonctions serverless | Lambda | Functions | Cloud Functions / Cloud Run |
| Droits d'accès | IAM | Entra ID + RBAC | IAM |
| Monitoring | CloudWatch | Azure Monitor / App Insights | Cloud Monitoring |
| DNS | Route 53 | Azure DNS | Cloud DNS |
| CI/CD intégré | CodePipeline / CodeBuild | Azure DevOps Pipelines | Cloud Build |
