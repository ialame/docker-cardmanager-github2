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
