#!/bin/bash
echo "📦 Import de vos données réelles dans Docker..."

# 1. Vérifier que votre base locale fonctionne
echo "🔍 Vérification de votre base locale localhost:3306/dev..."
if ! mysql -h localhost -P 3306 -u ia -pfoufafou -e "SELECT 'Connexion OK' AS status;" dev 2>/dev/null; then
    echo "❌ Impossible de se connecter à votre base locale localhost:3306/dev"
    echo "💡 Vérifiez que votre MySQL/MariaDB local fonctionne :"
    echo "   • macOS: brew services start mysql"
    echo "   • Linux: sudo systemctl start mysql"
    echo "   • Windows: Démarrer le service MySQL"
    echo ""
    echo "🔧 Ou modifiez les paramètres de connexion dans ce script"
    exit 1
fi

echo "✅ Connexion à votre base locale réussie"

# 2. Compter vos données
table_count=$(mysql -h localhost -P 3306 -u ia -pfoufafou -D dev -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='dev';" -s -N 2>/dev/null)
echo "📊 Votre base locale contient $table_count tables"

if [ "$table_count" -eq "0" ]; then
    echo "⚠️  Votre base locale semble vide. Êtes-vous sûr des paramètres ?"
    echo "💡 Vérifiez : mysql -h localhost -P 3306 -u ia -pfoufafou dev"
    exit 1
fi

# 3. Exporter vos données
echo "📤 Export de vos données locales..."
mkdir -p init-db

# Export du schéma
echo "  • Export du schéma..."
mysqldump -h localhost -P 3306 -u ia -pfoufafou \
    --no-data \
    --routines \
    --triggers \
    --events \
    --single-transaction \
    --quick \
    --lock-tables=false \
    dev > init-db/01-schema.sql

# Export des données
echo "  • Export des données..."
mysqldump -h localhost -P 3306 -u ia -pfoufafou \
    --no-create-info \
    --complete-insert \
    --single-transaction \
    --quick \
    --lock-tables=false \
    --hex-blob \
    dev > init-db/02-data.sql

# Script d'initialisation
cat > init-db/00-init.sql << 'EOF'
-- Initialisation CardManager avec données réelles
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';
SELECT 'Import des données réelles en cours...' AS message;
EOF

echo "✅ Export terminé"

# 4. Vérifier la taille des exports
schema_lines=$(wc -l < init-db/01-schema.sql)
data_lines=$(wc -l < init-db/02-data.sql)
echo "📊 Export : $schema_lines lignes de schéma, $data_lines lignes de données"

# 5. Arrêter GestionCarte qui boucle
echo "🛑 Arrêt des services qui posent problème..."
docker-compose down

# 6. Supprimer le volume de base pour repartir à zéro
echo "🗑️ Suppression de la base Docker vide..."
docker volume rm docker-cardmanager-github_cardmanager_db_data 2>/dev/null || echo "Volume déjà supprimé"

# 7. Créer un docker-compose avec import automatique des données
echo "📝 Configuration Docker avec import de vos données..."
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
      # IMPORT AUTOMATIQUE de vos données au premier démarrage
      - ./init-db:/docker-entrypoint-initdb.d:ro
    networks:
      - cardmanager-network
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      start_period: 120s  # Plus de temps pour l'import
      interval: 10s
      timeout: 10s
      retries: 20
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
      - SPRING_JPA_HIBERNATE_DDL_AUTO=validate  # Ne pas modifier le schéma
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
      # DÉSACTIVER Liquibase car les données sont déjà là
      - SPRING_LIQUIBASE_ENABLED=false
      - SPRING_JPA_HIBERNATE_DDL_AUTO=validate  # Valider seulement, ne pas modifier
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

# 8. Démarrer avec import automatique
echo "🚀 Démarrage avec import de vos données réelles..."
echo "⏳ L'import peut prendre plusieurs minutes selon la taille de vos données..."

docker-compose up -d

# 9. Suivre l'import en temps réel
echo "📋 Suivi de l'import des données :"
timeout=300  # 5 minutes max pour l'import
while ! docker-compose exec mariadb-standalone mysqladmin ping -h localhost --silent 2>/dev/null; do
    echo "  Import en cours... ($timeout secondes restantes)"
    sleep 10
    timeout=$((timeout-10))
    if [ $timeout -le 0 ]; then
        echo "❌ Timeout lors de l'import"
        echo "📋 Logs MariaDB :"
        docker-compose logs mariadb-standalone
        exit 1
    fi
done

# 10. Vérifier que vos données sont bien importées
echo "🔍 Vérification de l'import..."
imported_tables=$(docker-compose exec mariadb-standalone mysql -u ia -pfoufafou -D dev -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='dev';" -s -N 2>/dev/null)

if [ "$imported_tables" -ge "$table_count" ]; then
    echo "✅ Import réussi ! $imported_tables tables importées"

    # 11. Attendre que tous les services démarrent
    echo "⏳ Attente du démarrage complet des applications..."
    sleep 60

    # 12. Vérifier l'état final
    echo "📊 État final des services :"
    docker-compose ps

    echo ""
    echo "🎉 SUCCÈS ! CardManager avec vos données réelles est opérationnel !"
    echo ""
    echo "🌐 URLs d'accès :"
    echo "   • Application (avec VOS données) : http://localhost:8080"
    echo "   • Service Painter : http://localhost:8081"
    echo "   • Serveur d'images : http://localhost:8082/images/"
    echo "   • Base de données : localhost:3307 (ia/foufafou)"
    echo ""
    echo "🔍 Test rapide :"
    echo "   curl http://localhost:8080/api/health || echo 'App en cours de démarrage...'"

else
    echo "❌ Problème d'import : seulement $imported_tables tables importées sur $table_count attendues"
    echo "📋 Logs pour diagnostic :"
    docker-compose logs mariadb-standalone
fi