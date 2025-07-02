# 🎯 CardManager - Système de Gestion de Cartes à Jouer

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/ialame/docker-cardmanager-github)
[![Docker](https://img.shields.io/badge/docker-ready-green.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

> **Système complet de gestion de collections de cartes à jouer avec Docker**

## 🚀 Démarrage en 3 étapes

```bash
git clone https://github.com/ialame/docker-cardmanager-github.git
cd docker-cardmanager-github
docker-compose up -d
```

**📱 Accédez à l'application :** http://localhost:8080

## 📚 Documentation

### 🇫🇷 Guides en français
- **[📖 Guide de déploiement](docs/DEPLOIEMENT-FR.md)** - Installation complète
- **[🔧 Guide technique](docs/TECHNIQUE-FR.md)** - Configuration avancée
- **[❓ FAQ](docs/FAQ-FR.md)** - Questions fréquentes

### 🇺🇸 English guides
- **[📖 Deployment guide](docs/DEPLOYMENT-EN.md)** - Complete installation
- **[🔧 Technical guide](docs/TECHNICAL-EN.md)** - Advanced configuration
- **[❓ FAQ](docs/FAQ-EN.md)** - Frequently asked questions

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GestionCarte  │◄──►│     Painter      │◄──►│     Mason       │
│   (Port 8080)   │    │   (Port 8081)    │    │  (Bibliothèque) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  ▼
                        ┌─────────────────┐
                        │     MariaDB     │
                        │   (Port 3307)   │
                        └─────────────────┘
```

- **GestionCarte** : Interface web principale
- **Painter** : Service de gestion d'images
- **Mason** : Bibliothèque partagée
- **MariaDB** : Base de données
- **Nginx** : Serveur d'images (port 8082)

## ⚡ Scripts rapides

| Script | Description |
|--------|-------------|
| `./start.sh` | Démarrer tous les services |
| `./stop.sh` | Arrêter tous les services |
| `./backup.sh` | Sauvegarder les données |
| `./status.sh` | Vérifier l'état des services |
| `./diagnostic.sh` | Diagnostic automatique |

## 🎯 Liens utiles

- **Application :** http://localhost:8080
- **API Painter :** http://localhost:8081
- **Images :** http://localhost:8082/images/
- **Base de données :** localhost:3307

## 🆘 Support

1. **Consultez d'abord** la [FAQ française](docs/FAQ-FR.md) ou [FAQ anglaise](docs/FAQ-EN.md)
2. **Problème technique ?** Voir le [guide technique](docs/TECHNIQUE-FR.md)
3. **Bug report :** [Issues GitHub](https://github.com/ialame/docker-cardmanager-github/issues)

---

**Développé avec ❤️ pour les collectionneurs de cartes**
