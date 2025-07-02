# 🚀 Guide de Déploiement CardManager

**Version :** 1.0.0  
**Date :** Juillet 2025  
**Audience :** Utilisateurs finaux et administrateurs

---

## 📋 Table des matières

1. [Prérequis](#prérequis)
2. [Installation rapide](#installation-rapide)
3. [Vérification du déploiement](#vérification-du-déploiement)
4. [Utilisation](#utilisation)
5. [Maintenance](#maintenance)
6. [Dépannage](#dépannage)
7. [Support](#support)

---

## 🔧 Prérequis

### Logiciels requis

**Obligatoire :**
- ✅ **Docker Desktop** (version 20.10 ou plus récente)
- ✅ **Git** (pour télécharger le projet)
- ✅ **Navigateur web** moderne (Chrome, Firefox, Safari, Edge)

**Recommandé :**
- 💻 **4 GB de RAM** minimum
- 💾 **10 GB d'espace disque** libre
- 🌐 **Connexion internet** (pour le téléchargement initial)

### Installation de Docker

#### Windows
1. Téléchargez **Docker Desktop** depuis [docker.com](https://www.docker.com/products/docker-desktop)
2. Lancez l'installateur et suivez les instructions
3. Redémarrez votre ordinateur
4. Ouvrez Docker Desktop et attendez qu'il démarre

#### macOS
1. Téléchargez **Docker Desktop for Mac** depuis [docker.com](https://www.docker.com/products/docker-desktop)
2. Glissez Docker dans le dossier Applications
3. Lancez Docker Desktop
4. Autorisez les permissions si demandé

#### Linux (Ubuntu/Debian)
```bash
# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Démarrer Docker
sudo systemctl start docker
sudo systemctl enable docker

# Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER
```

---

## ⚡ Installation rapide

### Étape 1 : Télécharger le projet

```bash
# Ouvrir un terminal/invite de commandes
git clone https://github.com/ialame/docker-cardmanager-github.git
cd docker-cardmanager-github
```

### Étape 2 : Lancer l'installation

**Sur Windows :**
```cmd
start.bat
```

**Sur macOS/Linux :**
```bash
./start.sh
```

### Étape 3 : Attendre le démarrage

⏳ **Patience !** Le premier démarrage peut prendre 5-10 minutes :
- Téléchargement des images Docker
- Construction des services
- Initialisation de la base de données

🎯 **Vous verrez ce message quand c'est prêt :**
```
✅ CardManager démarré !

📡 URLs d'accès :
   - Application : http://localhost:8080
   - Images : http://localhost:8082/images/
```

---

## ✅ Vérification du déploiement

### Tests automatiques

1. **Ouvrez votre navigateur** et allez sur : `http://localhost:8080`
2. **Vous devriez voir** l'interface CardManager
3. **Testez le serveur d'images** : `http://localhost:8082/images/`

### Vérification manuelle

```bash
# Vérifier que tous les services fonctionnent
docker-compose ps
```

**Résultat attendu :**
```
NAME                     STATUS
cardmanager-gestioncarte Up (healthy)
cardmanager-painter      Up (healthy)  
cardmanager-nginx        Up
cardmanager-mariadb      Up (healthy)
cardmanager-mason        Up
```

---

## 🎯 Utilisation

### Interface principale

**URL :** `http://localhost:8080`

#### Fonctionnalités disponibles :
- 📇 **Gestion des cartes** : Ajouter, modifier, supprimer
- 🖼️ **Upload d'images** : Glisser-déposer vos images de cartes
- 🔍 **Recherche** : Trouver rapidement vos cartes
- 📊 **Tableaux de bord** : Vue d'ensemble de votre collection

#### Premier usage :
1. **Cliquez sur "Ajouter une carte"**
2. **Remplissez les informations** (nom, série, etc.)
3. **Glissez une image** dans la zone prévue
4. **Sauvegardez** votre carte

### Consultation des images

**URL :** `http://localhost:8082/images/`

- 📁 **Navigation** par dossiers
- 🖼️ **Aperçu** des images uploadées
- 🔗 **Liens directs** vers chaque image

---

## 🔧 Maintenance

### Démarrage/Arrêt

#### Démarrer CardManager
```bash
# Windows
start.bat

# macOS/Linux  
./start.sh
```

#### Arrêter CardManager
```bash
# Windows
stop.bat

# macOS/Linux
./stop.sh
```

### Sauvegarde des données

#### Sauvegarde automatique
```bash
# Créer une sauvegarde complète
./backup.sh
```

#### Sauvegarde manuelle
```bash
# Sauvegarder les images
docker run --rm -v cardmanager_images:/source -v $(pwd):/backup alpine tar czf /backup/images-$(date +%Y%m%d).tar.gz -C /source .

# Sauvegarder la base de données
docker exec cardmanager-mariadb mysqldump -u ia -pfoufafou dev > backup-db-$(date +%Y%m%d).sql
```

### Mise à jour

```bash
# Télécharger les mises à jour
git pull

# Redémarrer avec les nouvelles versions
./stop.sh
./start.sh
```

---

## 🚨 Dépannage

### Problèmes courants

#### ❌ "Port already in use" (Port déjà utilisé)

**Problème :** Un autre service utilise les ports 8080, 8081 ou 8082.

**Solution :**
```bash
# Identifier le processus
lsof -i :8080
lsof -i :8081
lsof -i :8082

# Arrêter le processus ou modifier les ports dans docker-compose.yml
```

#### ❌ "Docker not found" (Docker non trouvé)

**Problème :** Docker n'est pas installé ou démarré.

**Solution :**
1. Vérifiez que Docker Desktop est installé
2. Démarrez Docker Desktop
3. Attendez que l'icône Docker soit verte

#### ❌ L'application ne répond pas

**Solution :**
```bash
# Redémarrer tous les services
./stop.sh
./start.sh

# Vérifier les logs
docker-compose logs -f
```

#### ❌ Les images ne s'affichent pas

**Solution :**
1. Vérifiez que vous avez uploadé des images via `http://localhost:8080`
2. Attendez quelques secondes après l'upload
3. Actualisez `http://localhost:8082/images/`

### Logs et diagnostic

```bash
# Voir tous les logs
docker-compose logs

# Logs d'un service spécifique
docker-compose logs gestioncarte
docker-compose logs painter

# Logs en temps réel
docker-compose logs -f
```

### Reset complet

⚠️ **ATTENTION : Supprime toutes les données !**

```bash
# Arrêter et supprimer toutes les données
docker-compose down --volumes

# Redémarrer proprement
./start.sh
```

---

## 📞 Support

### Informations système

En cas de problème, fournissez ces informations :

```bash
# Version Docker
docker --version
docker-compose --version

# État des services
docker-compose ps

# Logs récents
docker-compose logs --tail=50

# Système d'exploitation
uname -a  # Linux/macOS
ver       # Windows
```

### Auto-diagnostic

```bash
# Script de diagnostic automatique
./diagnostic.sh
```

### Contacts

- 📧 **Email support :** support@cardmanager.com
- 💬 **Chat :** Via l'interface web
- 📖 **Documentation :** https://docs.cardmanager.com
- 🐛 **Bugs :** https://github.com/ialame/docker-cardmanager-github/issues

---

## 📚 Annexes

### Configuration avancée

#### Modifier les ports

Éditez `docker-compose.yml` :
```yaml
ports:
  - "9080:8080"  # Application sur port 9080
  - "9081:8081"  # API sur port 9081
  - "9082:80"    # Images sur port 9082
```

#### Base de données externe

Pour utiliser votre propre base MariaDB :
```yaml
environment:
  - SPRING_DATASOURCE_URL=jdbc:mariadb://votre-db:3306/cardmanager
  - SPRING_DATASOURCE_USERNAME=votre_user
  - SPRING_DATASOURCE_PASSWORD=votre_password
```

### Limites et performances

- **Images max :** 10 MB par fichier
- **Formats supportés :** JPG, PNG, GIF, WebP
- **Utilisateurs concurrent :** 50+ (selon hardware)
- **Stockage :** Illimité (selon espace disque)

---

**🎉 Félicitations ! Votre CardManager est opérationnel !**

*Pour toute question, consultez la documentation ou contactez le support.*