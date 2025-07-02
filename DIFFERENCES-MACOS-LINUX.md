# 🔍 Différences MacOS vs Linux

## 🎯 Résumé rapide

**✅ 95% identique** - Les commandes Docker sont les mêmes
**⚠️ 5% différent** - Installation et permissions

## 📊 Tableau comparatif

| Aspect | MacOS | Linux |
|--------|-------|-------|
| **Installation Docker** | Docker Desktop (GUI) | apt/dnf/pacman (CLI) |
| **Permissions** | Automatiques | Groupe `docker` requis |
| **Scripts** | `./start.sh` identique | `./start.sh` identique |
| **URLs** | Identiques | Identiques |
| **Configuration** | Identique | Identique |
| **Navigateur** | `open` | `xdg-open` |
| **Ports** | `lsof` | `ss` ou `netstat` |

## 🎯 Recommandation

1. **Essayez d'abord** le guide MacOS/Linux standard
2. **Si problème sur Linux** → Guide Linux spécialisé
3. **En cas de doute** → Guide Linux spécialisé

## 🔧 Principales différences

### Installation Docker
- **MacOS :** Télécharger .dmg et installer
- **Linux :** Commandes package manager + groupe docker

### Après installation
- **Tout le reste est identique** ✅

## 💡 Conseil pratique

**Pour 90% des utilisateurs Linux** : Le guide MacOS/Linux suffit
**Pour administrateurs système** : Guide Linux spécialisé recommandé
