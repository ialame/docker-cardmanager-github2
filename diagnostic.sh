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
