@echo off
echo 🚀 Démarrage de CardManager...

REM Vérifier si Docker est disponible
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker n'est pas installé ou pas disponible
    echo Veuillez installer Docker Desktop depuis https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo 📦 Démarrage des services Docker...
docker-compose up -d

echo ⏳ Attente du démarrage des services...
timeout /t 10 /nobreak >nul

echo 📊 État des services :
docker-compose ps

echo.
echo ✅ CardManager démarré !
echo.
echo 📡 URLs d'accès :
echo    - Application : http://localhost:8080
echo    - Images : http://localhost:8082/images/
echo.
echo 🛑 Pour arrêter : stop.bat
pause
