## 🐧 Différences Linux vs MacOS

### 📦 Installation de Docker

#### MacOS (GUI)
```bash
# Télécharger Docker Desktop (interface graphique)
# Installer via .dmg
# Lancer Docker Desktop depuis Applications
```

#### Linux (ligne de commande)
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Fedora/CentOS/RHEL
sudo dnf install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Arch Linux
sudo pacman -S docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### 🔐 Permissions

#### MacOS
```bash
# Généralement pas de problème de permissions
./start.sh  # Fonctionne directement
```

#### Linux
```bash
# Possible besoin de permissions sudo ou groupe docker
sudo ./start.sh  # Si pas dans le groupe docker
# OU (après logout/login)
./start.sh  # Si ajouté au groupe docker
```

### 🌐 Navigateur par défaut

#### MacOS
```bash
# start.sh peut utiliser
open http://localhost:8080
```

#### Linux
```bash
# start.sh doit utiliser
xdg-open http://localhost:8080
# OU
firefox http://localhost:8080
# OU
google-chrome http://localhost:8080
```

### 📁 Chemins de fichiers

#### MacOS
```bash
# Volumes Docker dans
/var/lib/docker/volumes/  # Via Docker Desktop
```

#### Linux
```bash
# Volumes Docker dans
/var/lib/docker/volumes/  # Accès direct système
```

### 🔧 Outils système

#### MacOS
```bash
# Commandes macOS spécifiques
lsof -i :8080           # Voir les ports
brew install git        # Installation avec Homebrew
```

#### Linux
```bash
# Commandes Linux équivalentes
netstat -tulpn | grep 8080  # Voir les ports
ss -tulpn | grep 8080       # Alternative moderne
sudo apt install git       # Ubuntu/Debian
sudo dnf install git       # Fedora
sudo pacman -S git         # Arch
```