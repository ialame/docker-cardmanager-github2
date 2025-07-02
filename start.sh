#!/bin/bash
echo "🚀 Démarrage de CardManager..."

# Vérifier que Docker est disponible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé ou pas disponible"
    echo "💡 Installez Docker Desktop depuis https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Vérifier si les images existent
IMAGES_EXIST=true
for image in docker-cardmanager-mason docker-cardmanager-painter docker-cardmanager-gestioncarte; do
    if ! docker image inspect "${image}:latest" >/dev/null 2>&1; then
        IMAGES_EXIST=false
        break
    fi
done

# Si les images n'existent pas, les construire
if [ "$IMAGES_EXIST" = false ]; then
    echo "🏗️ Première installation détectée - Construction des images..."
    echo "⏳ Cela peut prendre 10-15 minutes..."
    echo ""

    # Lancer le build complet
    if [ -f "build.sh" ]; then
        chmod +x build.sh
        ./build.sh
    else
        echo "📦 Construction avec Docker Compose..."

        # Utiliser docker compose ou docker-compose selon la version
        if command -v docker-compose &> /dev/null; then
            docker-compose build --no-cache
        else
            docker compose build --no-cache
        fi

        echo "🚀 Démarrage des services..."
        if command -v docker-compose &> /dev/null; then
            docker-compose up -d
        else
            docker compose up -d
        fi
    fi
else
    echo "📦 Démarrage des services existants..."

    # Démarrer les services
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d
    else
        docker compose up -d
    fi
fi

# Attendre le démarrage
echo "⏳ Attente du démarrage des services..."
sleep 15

# Vérifier l'état
echo "📊 État des services :"
if command -v docker-compose &> /dev/null; then
    docker-compose ps
else
    docker compose ps
fi

echo ""
echo "✅ CardManager démarré !"
echo ""
echo "📡 URLs d'accès :"
echo "   - Application : http://localhost:8080"
echo "   - Images : http://localhost:8082/images/"
echo ""
echo "🛑 Pour arrêter : ./stop.sh"
echo "📋 Pour voir les logs : docker-compose logs -f"