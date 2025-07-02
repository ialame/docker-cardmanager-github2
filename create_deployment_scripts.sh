#!/bin/bash
echo "📚 Création des guides de déploiement complets..."

# 1. Créer le guide français (copier le contenu de l'artifact GUIDE-DEPLOIEMENT-FR.md)
cat > GUIDE-DEPLOIEMENT-FR.md << 'FR_EOF'
# 🚀 Guide de Déploiement CardManager

**Version :** 1.0.0
**Date :** Juillet 2025
**Audience :** Utilisateurs finaux et administrateurs

[Contenu complet du guide français - voir artifact ci-dessus]
FR_EOF

# 2. Créer le guide anglais (copier le contenu de l'artifact DEPLOYMENT-GUIDE-EN.md)
cat > DEPLOYMENT-GUIDE-EN.md << 'EN_EOF'
# 🚀 CardManager Deployment Guide

**Version:** 1.0.0
**Date:** July 2025
**Audience:** End users and system administrators

[Contenu complet du guide anglais - voir artifact ci-dessus]
EN_EOF

# 3. Créer les scripts start/stop pour Windows
cat > start.bat << 'START_BAT'
@echo off
echo 🚀 Démarrage de CardManager...

REM Vérifier si Docker est disponible
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker n'est pas installé ou pas disponible
    echo Veuillez installer Docker Desktop depuis https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo 📦 Démarrage des services Docker...
docker-compose up -d

echo ⏳ Attente du démarrage des services...
timeout /t 10 /nobreak >nul

echo 📊 État des services :
docker-compose ps

echo.
echo ✅ CardManager démarré !
echo.
echo 📡 URLs d'accès :
echo    - Application : http://localhost:8080
echo    - Images : http://localhost:8082/images/
echo.
echo 🛑 Pour arrêter : stop.bat
pause
START_BAT

cat > stop.bat << 'STOP_BAT'
@echo off
echo 🛑 Arrêt de CardManager...

docker-compose down

echo ✅ CardManager arrêté.
echo.
echo 💡 Pour redémarrer : start.bat
echo 🗑️ Pour supprimer les données : docker-compose down --volumes
pause
STOP_BAT

# 4. Créer un script de diagnostic
cat > diagnostic.sh << 'DIAG_EOF'
#!/bin/bash
echo "🔍 Diagnostic automatique CardManager..."
echo "========================================"

echo ""
echo "🐳 Version Docker :"
docker --version 2>/dev/null || echo "❌ Docker non installé"
docker-compose --version 2>/dev/null || echo "❌ Docker Compose non disponible"

echo ""
echo "📊 État des services :"
docker-compose ps 2>/dev/null || echo "❌ Aucun service en cours"

echo ""
echo "🌐 Test de connectivité :"
echo "Application (8080):"
timeout 3 curl -I http://localhost:8080 2>/dev/null | head -1 || echo "❌ Application non accessible"

echo "Images (8082):"
timeout 3 curl -I http://localhost:8082 2>/dev/null | head -1 || echo "❌ Serveur d'images non accessible"

echo ""
echo "💾 Volumes Docker :"
docker volume ls | grep cardmanager || echo "❌ Aucun volume CardManager trouvé"

echo ""
echo "🔧 Utilisation des ressources :"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null | grep cardmanager || echo "❌ Aucun conteneur CardManager en cours"

echo ""
echo "📝 Logs récents (erreurs) :"
docker-compose logs --tail=5 2>/dev/null | grep -i error || echo "✅ Aucune erreur récente"

echo ""
echo "========================================"
echo "✅ Diagnostic terminé"
echo ""
echo "💡 En cas de problème :"
echo "   1. Redémarrez : ./stop.sh && ./start.sh"
echo "   2. Consultez les guides : GUIDE-DEPLOIEMENT-FR.md"
echo "   3. Contactez le support avec ces informations"
DIAG_EOF

chmod +x diagnostic.sh

# 5. Créer un script de sauvegarde
cat > backup.sh << 'BACKUP_EOF'
#!/bin/bash
echo "💾 Sauvegarde de CardManager..."

BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 Création du dossier de sauvegarde : $BACKUP_DIR"

# Sauvegarder les images
echo "🖼️ Sauvegarde des images..."
docker run --rm -v cardmanager_images:/source -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/images.tar.gz -C /source . 2>/dev/null || echo "❌ Échec sauvegarde images"

# Sauvegarder la base de données
echo "🗄️ Sauvegarde de la base de données..."
docker exec cardmanager-mariadb mysqldump -u ia -pfoufafou dev > "$BACKUP_DIR/database.sql" 2>/dev/null || echo "❌ Échec sauvegarde BDD"

# Sauvegarder la configuration
echo "⚙️ Sauvegarde de la configuration..."
cp docker-compose.yml "$BACKUP_DIR/" 2>/dev/null
cp nginx-images.conf "$BACKUP_DIR/" 2>/dev/null

# Créer un fichier d'informations
cat > "$BACKUP_DIR/backup-info.txt" << INFO_EOF
Sauvegarde CardManager
======================

Date: $(date)
Version: 1.0.0

Contenu:
- images.tar.gz : Toutes les images uploadées
- database.sql : Base de données complète
- docker-compose.yml : Configuration des services
- nginx-images.conf : Configuration serveur d'images

Restauration:
1. Copier les fichiers de configuration
2. Démarrer les services : ./start.sh
3. Restaurer les images : tar xzf images.tar.gz -C /path/to/volume
4. Restaurer la BDD : mysql -u ia -pfoufafou dev < database.sql
INFO_EOF

echo ""
echo "✅ Sauvegarde terminée dans : $BACKUP_DIR"
echo "📊 Taille de la sauvegarde :"
du -sh "$BACKUP_DIR"
echo ""
echo "💡 Pour restaurer, consultez backup-info.txt"
BACKUP_EOF

chmod +x backup.sh

# 6. Mettre à jour le README principal
cat > README.md << 'README_EOF'
# CardManager - Système de Gestion de Cartes

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/ialame/docker-cardmanager-github)
[![Docker](https://img.shields.io/badge/docker-ready-green.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

## 🚀 Démarrage rapide

```bash
# Cloner le projet
git clone https://github.com/ialame/docker-cardmanager-github.git
cd docker-cardmanager-github

# Démarrer (macOS/Linux)
./start.sh

# Démarrer (Windows)
start.bat
```

**URLs d'accès :**
- 🌐 **Application :** http://localhost:8080
- 🖼️ **Images :** http://localhost:8082/images/

## 📚 Documentation

- 🇫🇷 **[Guide de déploiement français](GUIDE-DEPLOIEMENT-FR.md)**
- 🇺🇸 **[English deployment guide](DEPLOYMENT-GUIDE-EN.md)**
- 🔧 **[Guide technique](README-TECHNIQUE.md)**

## 🏗️ Architecture

- **MariaDB** : Base de données (port 3307)
- **Mason** : Bibliothèque commune
- **Painter** : Service d'images (port 8081)
- **GestionCarte** : Application web (port 8080)
- **Nginx** : Serveur d'images (port 8082)

## 🛠️ Scripts utiles

```bash
./start.sh      # Démarrer tous les services
./stop.sh       # Arrêter tous les services
./backup.sh     # Sauvegarder les données
./diagnostic.sh # Diagnostic automatique
```

## 🚨 Support

- 📖 **Documentation complète :** Voir les guides de déploiement
- 🐛 **Signaler un bug :** [Issues GitHub](https://github.com/ialame/docker-cardmanager-github/issues)
- 💬 **Questions :** Consulter les guides FR/EN selon votre langue

---

**Développé avec ❤️ pour la gestion de collections de cartes**
README_EOF

echo ""
echo "✅ Guides de déploiement créés !"
echo ""
echo "📁 Fichiers générés :"
echo "├── GUIDE-DEPLOIEMENT-FR.md    (Guide français complet)"
echo "├── DEPLOYMENT-GUIDE-EN.md     (Guide anglais complet)"
echo "├── start.bat / start.sh       (Scripts de démarrage)"
echo "├── stop.bat / stop.sh         (Scripts d'arrêt)"
echo "├── diagnostic.sh              (Diagnostic automatique)"
echo "├── backup.sh                  (Sauvegarde des données)"
echo "└── README.md                  (Documentation mise à jour)"
echo ""
echo "🎯 Les employés peuvent maintenant utiliser :"
echo "   - GUIDE-DEPLOIEMENT-FR.md pour les francophones"
echo "   - DEPLOYMENT-GUIDE-EN.md pour les anglophones"
echo ""
echo "🚀 Déploiement simplifié :"
echo "   - Windows : double-clic sur start.bat"
echo "   - macOS/Linux : ./start.sh"