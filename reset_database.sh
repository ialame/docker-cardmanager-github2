#!/bin/bash
echo "🗄️ Réinitialisation complète de la base de données..."

# 1. Arrêter tous les services
echo "🛑 Arrêt de tous les services..."
docker-compose down

# 2. Supprimer SEULEMENT le volume de la base de données (garder les images)
echo "🧹 Suppression du volume de base de données..."
docker volume rm docker-cardmanager-github_cardmanager_db_data 2>/dev/null || echo "Volume déjà supprimé"

# 3. Recréer une configuration compatible
echo "📝 Configuration avec Hibernate DDL-AUTO au lieu de Liquibase..."
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
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
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
      # Configuration pour éviter le conflit Liquibase
      - SPRING_LIQUIBASE_ENABLED=false
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
      - SPRING_JPA_DEFER_DATASOURCE_INITIALIZATION=true
    ports:
      - "8080:8080"
    networks:
      - cardmanager-network
    restart: unless-stopped

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

# 4. Redémarrer avec une base vide
echo "🚀 Redémarrage avec une base de données fraîche..."
docker-compose up -d

# 5. Attendre le démarrage
echo "⏳ Attente du démarrage complet (60 secondes)..."
sleep 60

# 6. Vérifier l'état
echo "📊 État des services :"
docker-compose ps

echo ""
echo "🔍 Test de connectivité :"
echo "• MariaDB: $(docker-compose exec mariadb-standalone mysqladmin ping -h localhost --silent 2>/dev/null && echo "✅ OK" || echo "❌ KO")"
echo "• Painter: $(curl -s -I http://localhost:8081 | grep -q "HTTP/1.1" && echo "✅ OK" || echo "❌ KO")"
echo "• GestionCarte: $(curl -s -I http://localhost:8080 | grep -q "HTTP/1.1" && echo "✅ OK" || echo "❌ KO")"
echo "• Nginx: $(curl -s -I http://localhost:8082 | grep -q "HTTP/1.1" && echo "✅ OK" || echo "❌ KO")"

echo ""
echo "📋 Logs récents de GestionCarte :"
docker-compose logs --tail=15 gestioncarte

echo ""
echo "🎯 URLs d'accès :"
echo "   • Application principale: http://localhost:8080"
echo "   • Service Painter: http://localhost:8081"
echo "   • Serveur d'images: http://localhost:8082/images/"
echo "   • Base MariaDB: localhost:3307 (ia/foufafou)"

echo ""
echo "📝 Cette configuration utilise Hibernate DDL-AUTO au lieu de Liquibase"
echo "   pour éviter les conflits de migration de schéma."