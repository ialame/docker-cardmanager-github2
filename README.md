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
# docker-cardmanager-github2
# docker-cardmanager-github2
