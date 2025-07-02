#!/bin/bash
echo "📸 Import de vos images dans Docker..."

# 1. Chercher vos images sur le système local
echo "🔍 Recherche de vos images locales..."

# Dossiers probables où chercher des images
SEARCH_PATHS=(
    "/Users/ibrahimalame/images"
    "/Users/ibrahimalame/Documents/images"
    "/Users/ibrahimalame/Pictures"
    "/Users/ibrahimalame/Desktop/images"
    "$HOME/images"
    "$HOME/Pictures"
    "$HOME/Documents/images"
)

FOUND_IMAGES=()
for path in "${SEARCH_PATHS[@]}"; do
    if [ -d "$path" ]; then
        count=$(find "$path" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) 2>/dev/null | wc -l)
        if [ "$count" -gt 0 ]; then
            echo "📁 Trouvé $count images dans : $path"
            FOUND_IMAGES+=("$path")
        fi
    fi
done

if [ ${#FOUND_IMAGES[@]} -eq 0 ]; then
    echo "❌ Aucun dossier d'images trouvé automatiquement"
    echo "💡 Spécifiez manuellement votre dossier :"
    echo "   docker cp /your/image/folder/* cardmanager-painter:/app/images/"
    echo ""
    echo "🔍 Pour chercher manuellement :"
    echo "   find /Users -name '*.jpg' -o -name '*.png' 2>/dev/null | head -10"
    exit 1
fi

# 2. Demander à l'utilisateur quel dossier utiliser
echo ""
echo "📋 Dossiers d'images trouvés :"
for i in "${!FOUND_IMAGES[@]}"; do
    count=$(find "${FOUND_IMAGES[$i]}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) 2>/dev/null | wc -l)
    echo "   $((i+1)). ${FOUND_IMAGES[$i]} ($count images)"
done

echo ""
read -p "🎯 Choisissez le dossier à importer (1-${#FOUND_IMAGES[@]}) ou 'q' pour quitter : " choice

if [ "$choice" = "q" ]; then
    echo "❌ Import annulé"
    exit 0
fi

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#FOUND_IMAGES[@]} ]; then
    echo "❌ Choix invalide"
    exit 1
fi

SELECTED_PATH="${FOUND_IMAGES[$((choice-1))]}"
echo "✅ Dossier sélectionné : $SELECTED_PATH"

# 3. Vérifier l'espace disponible
echo "📊 Calcul de la taille des images..."
total_size=$(find "$SELECTED_PATH" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) -exec du -c {} + 2>/dev/null | tail -1 | cut -f1)
total_size_mb=$((total_size / 1024))

echo "📦 Taille totale à copier : ${total_size_mb} MB"

if [ "$total_size_mb" -gt 1000 ]; then
    echo "⚠️  Grande quantité d'images (${total_size_mb} MB)"
    read -p "🤔 Continuer l'import ? (y/N) : " confirm
    if [ "$confirm" != "y" ]; then
        echo "❌ Import annulé"
        exit 0
    fi
fi

# 4. Nettoyer les fichiers de test d'abord
echo "🧹 Nettoyage des fichiers de test..."
docker-compose exec painter rm -f /app/images/test*.txt
docker-compose exec painter rm -rf /app/images/test/

# 5. Copier les images
echo "📤 Copie des images vers Docker..."
echo "⏳ Cela peut prendre du temps selon la quantité d'images..."

# Copier par petits lots pour éviter les timeouts
find "$SELECTED_PATH" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | while IFS= read -r file; do
    # Garder la structure de dossiers relative
    relative_path=$(echo "$file" | sed "s|^$SELECTED_PATH/||")
    target_dir=$(dirname "$relative_path")

    # Créer le dossier cible si nécessaire
    if [ "$target_dir" != "." ]; then
        docker-compose exec painter mkdir -p "/app/images/$target_dir"
    fi

    # Copier le fichier
    if docker cp "$file" "cardmanager-painter:/app/images/$relative_path" 2>/dev/null; then
        echo "✅ Copié : $relative_path"
    else
        echo "❌ Erreur : $relative_path"
    fi
done

# 6. Vérifier le résultat
echo "🔍 Vérification de l'import..."
imported_count=$(docker-compose exec painter find /app/images -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" \) | wc -l)
echo "📊 Images importées : $imported_count"

# 7. Test final
echo "🌐 Test du serveur d'images..."
curl -s http://localhost:8082/images/ | grep -o '<a href="[^"]*">' | head -10

echo ""
echo "🎉 Import terminé !"
echo ""
echo "🌐 Vos images sont maintenant disponibles sur :"
echo "   http://localhost:8082/images/"
echo ""
echo "📋 Commandes de test :"
echo "   • Navigation : open http://localhost:8082/images/"
echo "   • Compter : docker-compose exec painter find /app/images -name '*.jpg' | wc -l"
echo "   • Taille : docker-compose exec painter du -sh /app/images"