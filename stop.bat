@echo off
echo 🛑 Arrêt de CardManager...

docker-compose down

echo ✅ CardManager arrêté.
echo.
echo 💡 Pour redémarrer : start.bat
echo 🗑️ Pour supprimer les données : docker-compose down --volumes
pause
