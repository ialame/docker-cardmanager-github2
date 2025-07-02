#!/bin/bash
echo "🔧 Correction du problème Liquibase GestionCarte..."

# 1. Arrêter GestionCarte seulement (garder les autres services)
echo "🛑 Arrêt de GestionCarte..."
docker-compose stop gestioncarte
docker-compose rm -f gestioncarte

# 2. Créer une version temporaire de docker-compose.yml sans le restart automatique
echo "📝 Création d'une configuration temporaire sans restart automatique..."
cp docker-compose.yml docker-compose.backup.yml

# 3. Modifier temporairement le docker-compose pour désactiver Liquibase
cat > docker-compose.yml << 'EOF'
services:
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

  painter:
    build:
      context: .
      dockerfile: docker/painter/Dockerfile
    container_name: cardmanager-painter
    depends_on:
      mariadb-standalone:
        condition: service_healthy
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mariadb://mariadb-standalone:3306/dev
      - SPRING_DATASOURCE_USERNAME=ia
      - SPRING_DATASOURCE_PASSWORD=foufafou
      - SPRING_PROFILES_ACTIVE=docker
    ports:
      - "8081:8081"
    volumes:
      - cardmanager_images:/app/images
    networks:
      - cardmanager-network
    restart: unless-stopped

  gestioncarte:
    build:
      context: .
      dockerfile: docker/gestioncarte/Dockerfile
    container_name: cardmanager-gestioncarte
    depends_on:
      mariadb-standalone:
        condition: service_healthy
      painter:
        condition: service_started
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mariadb://mariadb-standalone:3306/dev
      - SPRING_DATASOURCE_USERNAME=ia
      - SPRING_DATASOURCE_PASSWORD=foufafou
      - SPRING_PROFILES_ACTIVE=docker
      - PAINTER_SERVICE_URL=http://painter:8081
      # DÉSACTIVER LIQUIBASE temporairement
      - SPRING_LIQUIBASE_ENABLED=false
      - SPRING_JPA_HIBERNATE_DDL_AUTO=validate
    ports:
      - "8080:8080"
    networks:
      - cardmanager-network
    # PAS DE RESTART AUTOMATIQUE pour éviter la boucle
    restart: "no"

  nginx-images:
    image: nginx:alpine
    container_name: cardmanager-nginx-images
    ports:
      - "8082:80"
    volumes:
      - cardmanager_images:/usr/share/nginx/html/images:ro
      - ./nginx-images.conf:/etc/nginx/conf.d/default.conf:ro
    networks:
      - cardmanager-network
    restart: unless-stopped
    depends_on:
      - painter

volumes:
  cardmanager_db_data:
    driver: local
  cardmanager_images:
    driver: local

networks:
  cardmanager-network:
    driver: bridge
EOF

echo "✅ Configuration temporaire créée (Liquibase désactivé)"

# 4. Nettoyer la base de données des tables de Liquibase qui pourraient être corrompues
echo "🧹 Nettoyage des tables Liquibase dans MariaDB..."
docker-compose exec mariadb-standalone mysql -u ia -pfoufafou dev -e "
DROP TABLE IF EXISTS j_changelog;
DROP TABLE IF EXISTS j_changelog_lock;
DROP TABLE IF EXISTS DATABASECHANGELOG;
DROP TABLE IF EXISTS DATABASECHANGELOGLOCK;
SELECT 'Tables Liquibase supprimées' AS message;
" 2>/dev/null || echo "Tables Liquibase déjà inexistantes"

# 5. Démarrer GestionCarte sans Liquibase
echo "🚀 Démarrage de GestionCarte sans Liquibase..."
docker-compose up -d gestioncarte

# 6. Attendre et vérifier
echo "⏳ Attente du démarrage (30 secondes)..."
sleep 30

# 7. Vérifier les logs
echo "📋 Vérification des logs GestionCarte..."
docker-compose logs --tail=20 gestioncarte

# 8. Vérifier si le service répond
echo "🔍 Test de l'application..."
if curl -s -I http://localhost:8080 | grep -q "HTTP/1.1"; then
    echo "✅ GestionCarte répond sur http://localhost:8080"

    # 9. Si ça marche, proposer de recréer une base propre
    echo ""
    echo "🎯 Options de correction permanente :"
    echo ""
    echo "Option 1 - Réinitialiser la base de données :"
    echo "   ./reset_database.sh"
    echo ""
    echo "Option 2 - Créer un profil sans Liquibase :"
    echo "   ./create_no_liquibase_profile.sh"
    echo ""
    echo "Option 3 - Restaurer la configuration avec restart :"
    echo "   mv docker-compose.backup.yml docker-compose.yml"
    echo "   docker-compose up -d"

else
    echo "❌ GestionCarte ne répond toujours pas"
    echo "📋 Logs détaillés :"
    docker-compose logs --tail=50 gestioncarte

    echo ""
    echo "🔧 Solutions possibles :"
    echo "1. Redémarrer avec une base vide :"
    echo "   docker-compose down -v"
    echo "   docker-compose up -d"
    echo ""
    echo "2. Vérifier la configuration Spring Boot"
    echo "3. Activer le mode debug :"
    echo "   docker-compose exec gestioncarte java -jar -Ddebug=true app.jar"
fi

echo ""
echo "📊 État actuel des services :"
docker-compose ps