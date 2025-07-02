#!/bin/bash
echo "🧹 Nettoyage du projet CardManager..."

# Créer un dossier de sauvegarde
BACKUP_DIR=".cleanup-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 Sauvegarde des fichiers dans $BACKUP_DIR..."

# 1. Sauvegarder les scripts de diagnostic/test
echo "💾 Sauvegarde des scripts de développement..."
mv debug_painter_config.sh "$BACKUP_DIR/" 2>/dev/null || true
mv fix_painter_storage.sh "$BACKUP_DIR/" 2>/dev/null || true
mv create_test_images.sh "$BACKUP_DIR/" 2>/dev/null || true
mv test_image_upload.sh "$BACKUP_DIR/" 2>/dev/null || true
mv monitor_uploads.sh "$BACKUP_DIR/" 2>/dev/null || true
mv fix_docker_config.sh "$BACKUP_DIR/" 2>/dev/null || true
mv fix_nginx_images.sh "$BACKUP_DIR/" 2>/dev/null || true

# 2. Sauvegarder les anciens docker-compose
echo "💾 Sauvegarde des anciennes configurations..."
mv docker-compose.yml.backup "$BACKUP_DIR/" 2>/dev/null || true
mv docker-compose.*.yml "$BACKUP_DIR/" 2>/dev/null || true

# 3. Nettoyer les images de test
echo "🗑️ Suppression des images de test..."
docker run --rm -v cardmanager_images:/images alpine sh -c "
rm -rf /images/test /images/pokemon /images/uploads /images/README.txt 2>/dev/null || true
echo 'Images de test supprimées'
"

# 4. Créer la structure finale propre
echo "📋 Création de la structure finale..."

# 5. Créer un README final
cat > README.md << 'EOF'
# CardManager - Système de Gestion de Cartes

## 🏗️ Architecture

- **MariaDB** : Base de données (port 3307)
- **Mason** : Bibliothèque commune
- **Painter** : Service de gestion d'images (port 8081)
- **GestionCarte** : Application principale (port 8080)
- **Nginx** : Serveur d'images (port 8082)

## 🚀 Démarrage

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier l'état
docker-compose ps

# Arrêter tous les services
docker-compose down
```

## 📡 Accès aux services

| Service | URL | Description |
|---------|-----|-------------|
| **Application** | http://localhost:8080 | Interface principale |
| **API Images** | http://localhost:8081 | API de traitement d'images |
| **Serveur Images** | http://localhost:8082/images/ | Consultation des images |
| **Base de données** | localhost:3307 | MariaDB (ia/foufafou) |

## 📂 Structure du projet

```
├── docker-compose.yml              # Configuration principale
├── nginx-images.conf               # Configuration Nginx
├── docker/                         # Dockerfiles des services
│   ├── mason/Dockerfile
│   ├── painter/Dockerfile
│   └── gestioncarte/Dockerfile
└── README.md                       # Cette documentation
```

## 🔧 Volumes persistants

- `cardmanager_db_data` : Données de la base de données
- `cardmanager_images` : Images stockées

## 🛠️ Maintenance

```bash
# Voir les logs
docker-compose logs -f [service_name]

# Redémarrer un service
docker-compose restart [service_name]

# Sauvegarder les images
docker run --rm -v cardmanager_images:/source -v $(pwd):/backup alpine tar czf /backup/images-backup.tar.gz -C /source .

# Nettoyer (⚠️ supprime les données)
docker-compose down --volumes
```

## 🚨 Dépannage

### Services qui ne démarrent pas
```bash
docker-compose logs [service_name]
docker-compose restart [service_name]
```

### Images non visibles
1. Vérifiez que l'upload fonctionne sur http://localhost:8080
2. Vérifiez le volume : `docker volume inspect cardmanager_images`
3. Redémarrez nginx : `docker-compose restart nginx-images`

---

**Version :** 1.0.0
**Dernière mise à jour :** $(date +%Y-%m-%d)
EOF

# 6. Créer un script de démarrage simple
cat > start.sh << 'EOF'
#!/bin/bash
echo "🚀 Démarrage de CardManager..."

# Vérifier que Docker est disponible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé ou pas disponible"
    exit 1
fi

# Démarrer les services
echo "📦 Démarrage des services Docker..."
docker-compose up -d

# Attendre le démarrage
echo "⏳ Attente du démarrage des services..."
sleep 10

# Vérifier l'état
echo "📊 État des services :"
docker-compose ps

echo ""
echo "✅ CardManager démarré !"
echo ""
echo "📡 URLs d'accès :"
echo "   - Application : http://localhost:8080"
echo "   - Images : http://localhost:8082/images/"
echo ""
echo "🛑 Pour arrêter : docker-compose down"
EOF

chmod +x start.sh

# 7. Créer un script d'arrêt propre
cat > stop.sh << 'EOF'
#!/bin/bash
echo "🛑 Arrêt de CardManager..."

docker-compose down

echo "✅ CardManager arrêté."
echo ""
echo "💡 Pour redémarrer : ./start.sh"
echo "🗑️ Pour supprimer les données : docker-compose down --volumes"
EOF

chmod +x stop.sh

# 8. Optimiser le docker-compose.yml final
cat > docker-compose.yml << 'EOF'
# CardManager - Configuration Docker Compose
# Version: 1.0.0

services:
  # Base de données MariaDB
  mariadb-standalone:
    image: mariadb:11.2
    container_name: cardmanager-mariadb
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: dev
      MYSQL_USER: ia
      MYSQL_PASSWORD: foufafou
    ports:
      - "3307:3306"
    volumes:
      - cardmanager_db_data:/var/lib/mysql
    networks:
      - cardmanager-network
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      start_period: 60s
      interval: 10s
      timeout: 5s
      retries: 10
    restart: unless-stopped

  # Service Mason (bibliothèque commune)
  mason:
    image: docker-cardmanager-mason:latest
    container_name: cardmanager-mason
    depends_on:
      mariadb-standalone:
        condition: service_healthy
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mariadb://mariadb-standalone:3306/dev
      - SPRING_DATASOURCE_USERNAME=ia
      - SPRING_DATASOURCE_PASSWORD=foufafou
      - SPRING_PROFILES_ACTIVE=docker
    networks:
      - cardmanager-network
    restart: unless-stopped

  # Service Painter (gestion d'images)
  painter:
    image: docker-cardmanager-painter:latest
    container_name: cardmanager-painter
    ports:
      - "8081:8081"
    depends_on:
      mariadb-standalone:
        condition: service_healthy
      mason:
        condition: service_started
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mariadb://mariadb-standalone:3306/dev
      - SPRING_DATASOURCE_USERNAME=ia
      - SPRING_DATASOURCE_PASSWORD=foufafou
      - SPRING_PROFILES_ACTIVE=docker
      - PAINTER_IMAGE_STORAGE_PATH=/app/images
    volumes:
      - cardmanager_images:/app/images
    networks:
      - cardmanager-network
    restart: unless-stopped

  # Application principale GestionCarte
  gestioncarte:
    image: docker-cardmanager-gestioncarte:latest
    container_name: cardmanager-gestioncarte
    ports:
      - "8080:8080"
    depends_on:
      mariadb-standalone:
        condition: service_healthy
      mason:
        condition: service_started
      painter:
        condition: service_started
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mariadb://mariadb-standalone:3306/dev
      - SPRING_DATASOURCE_USERNAME=ia
      - SPRING_DATASOURCE_PASSWORD=foufafou
      - SPRING_PROFILES_ACTIVE=docker
      - PAINTER_SERVICE_URL=http://painter:8081
      - SPRING_LIQUIBASE_ENABLED=false
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
    networks:
      - cardmanager-network
    restart: unless-stopped

  # Serveur d'images Nginx
  nginx-images:
    image: nginx:alpine
    container_name: cardmanager-nginx
    ports:
      - "8082:80"
    volumes:
      - cardmanager_images:/usr/share/nginx/html/images:ro
      - ./nginx-images.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - painter
    networks:
      - cardmanager-network
    restart: unless-stopped

# Volumes persistants
volumes:
  cardmanager_db_data:
    external: true
  cardmanager_images:
    external: true

# Réseau
networks:
  cardmanager-network:
    external: true
EOF

echo ""
echo "✅ Nettoyage terminé !"
echo ""
echo "📁 Structure finale du projet :"
echo "├── docker-compose.yml (optimisé)"
echo "├── nginx-images.conf"
echo "├── start.sh (démarrage simple)"
echo "├── stop.sh (arrêt propre)"
echo "├── README.md (documentation)"
echo "└── $BACKUP_DIR/ (fichiers sauvegardés)"
echo ""
echo "🚀 Pour utiliser votre projet :"
echo "   ./start.sh    # Démarrer"
echo "   ./stop.sh     # Arrêter"
echo ""
echo "📖 Consultez README.md pour la documentation complète."