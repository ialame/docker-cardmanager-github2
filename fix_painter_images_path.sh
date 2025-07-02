#!/bin/bash
echo "🔧 Correction du chemin d'images de Painter..."

# 1. Trouver où Painter stocke vraiment ses images
echo "🔍 Recherche du vrai dossier d'images de Painter..."
docker-compose exec painter find / -type d -name "*image*" 2>/dev/null || echo "Aucun dossier image trouvé"

# 2. Voir la configuration actuelle de Painter
echo "📋 Configuration Painter actuelle :"
docker-compose exec painter env | grep -i -E "(image|storage|path)"

# 3. Vérifier le contenu du JAR pour trouver les properties
echo "🔍 Recherche dans la configuration Spring Boot..."
docker-compose exec painter grep -r "storage-path\|image" /app/ 2>/dev/null || echo "Configuration non trouvée"

# 4. Modifier docker-compose.yml pour corriger le chemin
echo "📝 Modification de docker-compose.yml..."

# Sauvegarder l'original
cp docker-compose.yml docker-compose.yml.backup

# Ajouter la variable d'environnement manquante pour Painter
sed -i.bak '/- SPRING_PROFILES_ACTIVE=docker/a\
      - PAINTER_IMAGE_STORAGE_PATH=/app/images' docker-compose.yml

echo "✅ Variable PAINTER_IMAGE_STORAGE_PATH=/app/images ajoutée"

# 5. Redémarrer Painter avec la nouvelle configuration
echo "🔄 Redémarrage de Painter avec la nouvelle configuration..."
docker-compose stop painter
docker-compose up -d painter

# 6. Attendre le redémarrage
echo "⏳ Attente du redémarrage de Painter..."
sleep 15

# 7. Vérifier que Painter utilise maintenant le bon dossier
echo "🔍 Vérification de la nouvelle configuration..."
docker-compose exec painter env | grep PAINTER_IMAGE_STORAGE_PATH

# 8. Tester l'upload d'une image test
echo "📤 Test de création d'une image..."
docker-compose exec painter sh -c 'echo "Image test" > /app/images/test-painter.txt'

# 9. Vérifier qu'elle apparaît dans nginx
echo "🌐 Test de visibilité via nginx..."
curl -s http://localhost:8082/images/test-painter.txt

if curl -s http://localhost:8082/images/test-painter.txt | grep -q "Image test"; then
    echo "✅ SUCCESS! Painter stocke maintenant ses images dans le bon dossier"
    echo "🌐 Testez: http://localhost:8082/images/"
else
    echo "❌ Painter n'utilise toujours pas le bon dossier"
    echo "📋 Diagnostic approfondi nécessaire..."

    # Diagnostic approfondi
    echo "🔍 Configuration finale de Painter :"
    docker-compose exec painter env | grep -i image

    echo "🔍 Contenu de /app/images :"
    docker-compose exec painter ls -la /app/images/

    echo "🔍 Logs récents de Painter :"
    docker-compose logs --tail=10 painter
fi

echo ""
echo "📋 Commandes de test :"
echo "   • Voir les images : curl http://localhost:8082/images/"
echo "   • Upload via app : http://localhost:8080"
echo "   • Logs Painter : docker-compose logs -f painter"