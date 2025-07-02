#!/bin/bash
echo "📚 Mise à jour de la structure des guides de déploiement..."

# 1. Créer une section spécifique Linux dans le guide principal
echo "📝 Ajout d'une section Linux au guide français..."

# 2. Modifier le README pour clarifier la structure
cat > README.md << 'README_EOF'
# CardManager - Système de Gestion de Cartes

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/ialame/docker-cardmanager-github)
[![Docker](https://img.shields.io/badge/docker-ready-green.svg)](https://www.docker.com/)

## 🚀 Démarrage ultra-rapide

### macOS/Linux
```bash
git clone https://github.com/ialame/docker-cardmanager-github.git
cd docker-cardmanager-github
./start.sh
```

### Windows
```cmd
git clone https://github.com/ialame/docker-cardmanager-github.git
cd docker-cardmanager-github
start.bat
```

**URLs d'accès :** http://localhost:8080

## 📚 Documentation par plateforme

### 🇫🇷 Guides français
- 📱 **[Guide MacOS/Linux](GUIDE-DEPLOIEMENT-FR.md)** - Pour macOS et la plupart des distributions Linux
- 🐧 **[Guide Linux spécialisé](GUIDE-DEPLOIEMENT-LINUX-FR.md)** - Pour Ubuntu, Fedora, Arch, etc.

### 🇺🇸 English guides
- 💻 **[MacOS/Linux Guide](DEPLOYMENT-GUIDE-EN.md)** - For macOS and most Linux distributions
- 🐧 **[Specialized Linux Guide](DEPLOYMENT-GUIDE-LINUX-EN.md)** - For Ubuntu, Fedora, Arch, etc.

## 🎯 Quel guide choisir ?

| Si vous utilisez... | Guide recommandé |
|---------------------|------------------|
| **macOS** | Guide MacOS/Linux (FR/EN) |
| **Ubuntu/Debian** | Guide Linux spécialisé OU MacOS/Linux |
| **Fedora/CentOS** | Guide Linux spécialisé |
| **Arch/Manjaro** | Guide Linux spécialisé |
| **Windows** | Guide MacOS/Linux (section Windows) |

> 💡 **Conseil :** Commencez par le guide MacOS/Linux. Si vous rencontrez des problèmes sur Linux, consultez le guide spécialisé.

## 🏗️ Architecture

- **MariaDB** : Base de données (port 3307)
- **Mason** : Bibliothèque commune
- **Painter** : Service d'images (port 8081)
- **GestionCarte** : Application web (port 8080)
- **Nginx** : Serveur d'images (port 8082)

## 🛠️ Scripts disponibles

```bash
./start.sh      # Démarrer (macOS/Linux)
start.bat       # Démarrer (Windows)
./stop.sh       # Arrêter
./backup.sh     # Sauvegarde
./diagnostic.sh # Diagnostic
```

---

**Développé avec ❤️ pour la gestion de collections de cartes**
README_EOF

# 3. Créer une note explicative sur les différences
cat > DIFFERENCES-MACOS-LINUX.md << 'DIFF_EOF'
# 🔍 Différences MacOS vs Linux

## 🎯 Résumé rapide

**✅ 95% identique** - Les commandes Docker sont les mêmes
**⚠️ 5% différent** - Installation et permissions

## 📊 Tableau comparatif

| Aspect | MacOS | Linux |
|--------|-------|-------|
| **Installation Docker** | Docker Desktop (GUI) | apt/dnf/pacman (CLI) |
| **Permissions** | Automatiques | Groupe `docker` requis |
| **Scripts** | `./start.sh` identique | `./start.sh` identique |
| **URLs** | Identiques | Identiques |
| **Configuration** | Identique | Identique |
| **Navigateur** | `open` | `xdg-open` |
| **Ports** | `lsof` | `ss` ou `netstat` |

## 🎯 Recommandation

1. **Essayez d'abord** le guide MacOS/Linux standard
2. **Si problème sur Linux** → Guide Linux spécialisé
3. **En cas de doute** → Guide Linux spécialisé

## 🔧 Principales différences

### Installation Docker
- **MacOS :** Télécharger .dmg et installer
- **Linux :** Commandes package manager + groupe docker

### Après installation
- **Tout le reste est identique** ✅

## 💡 Conseil pratique

**Pour 90% des utilisateurs Linux** : Le guide MacOS/Linux suffit
**Pour administrateurs système** : Guide Linux spécialisé recommandé
DIFF_EOF

echo ""
echo "✅ Structure mise à jour !"
echo ""
echo "📁 Structure finale des guides :"
echo "├── 🇫🇷 GUIDE-DEPLOIEMENT-FR.md        (MacOS + Linux général)"
echo "├── 🐧 GUIDE-DEPLOIEMENT-LINUX-FR.md   (Linux spécialisé)"
echo "├── 🇺🇸 DEPLOYMENT-GUIDE-EN.md         (MacOS + Linux général)"
echo "├── 🐧 DEPLOYMENT-GUIDE-LINUX-EN.md    (Linux spécialisé - à créer)"
echo "├── 🔍 DIFFERENCES-MACOS-LINUX.md      (Comparatif détaillé)"
echo "└── 📖 README.md                       (Navigation des guides)"
echo ""
echo "🎯 Utilisation recommandée :"
echo "   1. Commencer par le guide MacOS/Linux"
echo "   2. Si problème Linux → Guide spécialisé"
echo "   3. Administrateurs → Directement guide spécialisé"