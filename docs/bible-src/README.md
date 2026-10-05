# Sources de la Bible DevOps & Cloud

Le PDF `../Bible-DevOps-Cloud.pdf` est généré à partir des fichiers Markdown de `chapters/` (un fichier par leçon ou par projet, dans l'ordre alphabétique).

## Régénérer le PDF

Prérequis : Node.js 20+, Python 3 avec `pypdf`, et un Chromium (le chemin est défini dans `build.mjs`, variable `executablePath`).

```bash
npm install
pip install pypdf
npm run build      # 1er passage, calcul des numéros de page du sommaire, 2e passage
```

## Syntaxe spéciale dans les chapitres

- `@@part Kicker | Titre | Description` : page de séparation de partie.
- `:::tip Titre` … `:::` : encadré (types : tip, warn, danger, info, why, check, clean, exo, interview, analogy, fix, card).
- ```` ```ascii ```` : schéma en texte (police à chasse fixe, taille ajustée automatiquement).
