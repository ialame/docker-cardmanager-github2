# 🚀 CardManager Deployment Guide

**Version:** 1.0.0  
**Date:** July 2025  
**Audience:** End users and system administrators

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Installation](#quick-installation)
3. [Deployment Verification](#deployment-verification)
4. [Usage](#usage)
5. [Maintenance](#maintenance)
6. [Troubleshooting](#troubleshooting)
7. [Support](#support)

---

## 🔧 Prerequisites

### Required Software

**Mandatory:**
- ✅ **Docker Desktop** (version 20.10 or newer)
- ✅ **Git** (to download the project)
- ✅ **Modern web browser** (Chrome, Firefox, Safari, Edge)

**Recommended:**
- 💻 **4 GB RAM** minimum
- 💾 **10 GB free disk space**
- 🌐 **Internet connection** (for initial download)

### Docker Installation

#### Windows
1. Download **Docker Desktop** from [docker.com](https://www.docker.com/products/docker-desktop)
2. Run the installer and follow instructions
3. Restart your computer
4. Open Docker Desktop and wait for it to start

#### macOS
1. Download **Docker Desktop for Mac** from [docker.com](https://www.docker.com/products/docker-desktop)
2. Drag Docker to Applications folder
3. Launch Docker Desktop
4. Allow permissions if requested

#### Linux (Ubuntu/Debian)
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group
sudo usermod -aG docker $USER
```

---

## ⚡ Quick Installation

### Step 1: Download the project

```bash
# Open terminal/command prompt
git clone https://github.com/ialame/docker-cardmanager-github.git
cd docker-cardmanager-github
```

### Step 2: Launch installation

**On Windows:**
```cmd
start.bat
```

**On macOS/Linux:**
```bash
./start.sh
```

### Step 3: Wait for startup

⏳ **Be patient!** First startup may take 5-10 minutes:
- Downloading Docker images
- Building services
- Database initialization

🎯 **You'll see this message when ready:**
```
✅ CardManager started!

📡 Access URLs:
   - Application: http://localhost:8080
   - Images: http://localhost:8082/images/
```

---

## ✅ Deployment Verification

### Automated Tests

1. **Open your browser** and go to: `http://localhost:8080`
2. **You should see** the CardManager interface
3. **Test the image server**: `http://localhost:8082/images/`

### Manual Verification

```bash
# Check that all services are running
docker-compose ps
```

**Expected result:**
```
NAME                     STATUS
cardmanager-gestioncarte Up (healthy)
cardmanager-painter      Up (healthy)  
cardmanager-nginx        Up
cardmanager-mariadb      Up (healthy)
cardmanager-mason        Up
```

---

## 🎯 Usage

### Main Interface

**URL:** `http://localhost:8080`

#### Available Features:
- 📇 **Card Management**: Add, edit, delete cards
- 🖼️ **Image Upload**: Drag & drop your card images
- 🔍 **Search**: Quickly find your cards
- 📊 **Dashboards**: Overview of your collection

#### First Use:
1. **Click "Add Card"**
2. **Fill in information** (name, series, etc.)
3. **Drag an image** to the designated area
4. **Save** your card

### Image Consultation

**URL:** `http://localhost:8082/images/`

- 📁 **Browse** by folders
- 🖼️ **Preview** uploaded images
- 🔗 **Direct links** to each image

---

## 🔧 Maintenance

### Start/Stop

#### Start CardManager
```bash
# Windows
start.bat

# macOS/Linux  
./start.sh
```

#### Stop CardManager
```bash
# Windows
stop.bat

# macOS/Linux
./stop.sh
```

### Data Backup

#### Automatic Backup
```bash
# Create complete backup
./backup.sh
```

#### Manual Backup
```bash
# Backup images
docker run --rm -v cardmanager_images:/source -v $(pwd):/backup alpine tar czf /backup/images-$(date +%Y%m%d).tar.gz -C /source .

# Backup database
docker exec cardmanager-mariadb mysqldump -u ia -pfoufafou dev > backup-db-$(date +%Y%m%d).sql
```

### Updates

```bash
# Download updates
git pull

# Restart with new versions
./stop.sh
./start.sh
```

---

## 🚨 Troubleshooting

### Common Issues

#### ❌ "Port already in use"

**Problem:** Another service is using ports 8080, 8081, or 8082.

**Solution:**
```bash
# Identify the process
lsof -i :8080
lsof -i :8081
lsof -i :8082

# Stop the process or modify ports in docker-compose.yml
```

#### ❌ "Docker not found"

**Problem:** Docker is not installed or started.

**Solution:**
1. Check that Docker Desktop is installed
2. Start Docker Desktop
3. Wait for Docker icon to turn green

#### ❌ Application not responding

**Solution:**
```bash
# Restart all services
./stop.sh
./start.sh

# Check logs
docker-compose logs -f
```

#### ❌ Images not displaying

**Solution:**
1. Verify you uploaded images via `http://localhost:8080`
2. Wait a few seconds after upload
3. Refresh `http://localhost:8082/images/`

### Logs and Diagnostics

```bash
# View all logs
docker-compose logs

# Logs for specific service
docker-compose logs gestioncarte
docker-compose logs painter

# Real-time logs
docker-compose logs -f
```

### Complete Reset

⚠️ **WARNING: Deletes all data!**

```bash
# Stop and remove all data
docker-compose down --volumes

# Clean restart
./start.sh
```

---

## 📞 Support

### System Information

In case of issues, provide this information:

```bash
# Docker version
docker --version
docker-compose --version

# Service status
docker-compose ps

# Recent logs
docker-compose logs --tail=50

# Operating system
uname -a  # Linux/macOS
ver       # Windows
```

### Auto-Diagnosis

```bash
# Automatic diagnostic script
./diagnostic.sh
```

### Contacts

- 📧 **Support email:** support@cardmanager.com
- 💬 **Chat:** Via web interface
- 📖 **Documentation:** https://docs.cardmanager.com
- 🐛 **Bug reports:** https://github.com/ialame/docker-cardmanager-github/issues

---

## 📚 Appendices

### Advanced Configuration

#### Modify Ports

Edit `docker-compose.yml`:
```yaml
ports:
  - "9080:8080"  # Application on port 9080
  - "9081:8081"  # API on port 9081
  - "9082:80"    # Images on port 9082
```

#### External Database

To use your own MariaDB database:
```yaml
environment:
  - SPRING_DATASOURCE_URL=jdbc:mariadb://your-db:3306/cardmanager
  - SPRING_DATASOURCE_USERNAME=your_user
  - SPRING_DATASOURCE_PASSWORD=your_password
```

### Limits and Performance

- **Max image size:** 10 MB per file
- **Supported formats:** JPG, PNG, GIF, WebP
- **Concurrent users:** 50+ (depending on hardware)
- **Storage:** Unlimited (depending on disk space)

---

**🎉 Congratulations! Your CardManager is operational!**

*For any questions, consult the documentation or contact support.*