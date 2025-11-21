# Guide de Dépannage MinIO - Erreur 502 Bad Gateway

## 🔴 Problème Identifié

L'erreur **502 Bad Gateway** indique que :
- ✅ Nginx fonctionne et répond (on reçoit une réponse HTTP)
- ❌ Nginx ne peut **pas** se connecter à MinIO en arrière-plan

## 🔍 Diagnostic

### Test de Connexion
```bash
curl -I https://s3.minio.51.75.73.102.nip.io:443
```

**Résultat attendu** : `HTTP/1.1 502 Bad Gateway`

Cela confirme que :
1. Le DNS fonctionne (résolution de `s3.minio.51.75.73.102.nip.io`)
2. Nginx est accessible sur le port 443
3. Nginx ne peut pas joindre MinIO

## 🛠️ Solutions

### 1. Vérifier que MinIO est Démarré

**Sur le serveur**, vérifiez si MinIO est en cours d'exécution :

```bash
# Vérifier les processus MinIO
ps aux | grep minio

# Ou avec Docker
docker ps | grep minio

# Vérifier les logs MinIO
docker logs <container_minio>
# ou
journalctl -u minio -n 50
```

**Solution** : Si MinIO n'est pas démarré, démarrez-le :
```bash
# Avec Docker
docker start <container_minio>

# Ou avec systemd
sudo systemctl start minio
```

### 2. Vérifier le Port de MinIO

MinIO écoute généralement sur le port **9000** (API) et **9001** (Console).

**Vérifier** :
```bash
# Vérifier les ports ouverts
netstat -tlnp | grep 9000
# ou
ss -tlnp | grep 9000
```

**Solution** : Si MinIO n'écoute pas, vérifiez la configuration :
```bash
# Variables d'environnement MinIO
MINIO_ROOT_USER=moez@ght
MINIO_ROOT_PASSWORD=12547?ghT
MINIO_BROWSER_REDIRECT_URL=https://s3.minio.51.75.73.102.nip.io
```

### 3. Vérifier la Configuration Nginx

**Fichier de configuration Nginx** (généralement `/etc/nginx/sites-available/minio` ou similaire) :

```nginx
upstream minio_backend {
    server 127.0.0.1:9000;  # Vérifier que c'est le bon port
    # ou
    # server minio:9000;  # Si MinIO est dans un container Docker
}

server {
    listen 443 ssl;
    server_name s3.minio.51.75.73.102.nip.io;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://minio_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
    }
}
```

**Vérifications** :
1. ✅ Le port dans `upstream` correspond au port MinIO (généralement 9000)
2. ✅ L'adresse IP/hostname est correcte (127.0.0.1 si même serveur, ou nom du container Docker)
3. ✅ Les certificats SSL sont valides

**Solution** : Après modification, recharger Nginx :
```bash
sudo nginx -t  # Tester la configuration
sudo systemctl reload nginx  # Recharger Nginx
```

### 4. Vérifier la Connectivité entre Nginx et MinIO

**Sur le serveur**, tester la connexion :

```bash
# Depuis le serveur, tester la connexion à MinIO
curl -I http://127.0.0.1:9000
# ou si MinIO est dans un container
curl -I http://minio:9000
```

**Résultat attendu** :
- ✅ `HTTP/1.1 200 OK` ou `HTTP/1.1 403 Forbidden` → MinIO répond
- ❌ `Connection refused` → MinIO n'écoute pas sur ce port
- ❌ `Connection timeout` → Problème de réseau/firewall

### 5. Vérifier le Firewall

**Vérifier** que le port 9000 n'est pas bloqué :

```bash
# Ubuntu/Debian
sudo ufw status
sudo ufw allow 9000/tcp

# CentOS/RHEL
sudo firewall-cmd --list-ports
sudo firewall-cmd --add-port=9000/tcp --permanent
sudo firewall-cmd --reload
```

### 6. Vérifier les Logs Nginx

**Consulter les logs d'erreur Nginx** :

```bash
# Logs d'erreur
sudo tail -f /var/log/nginx/error.log

# Logs d'accès
sudo tail -f /var/log/nginx/access.log
```

**Rechercher** des erreurs comme :
- `connect() failed (111: Connection refused)`
- `upstream timed out`
- `no live upstreams`

## 🔧 Solutions Rapides

### Solution 1 : Redémarrer MinIO
```bash
# Docker
docker restart <container_minio>

# Systemd
sudo systemctl restart minio
```

### Solution 2 : Redémarrer Nginx
```bash
sudo systemctl restart nginx
```

### Solution 3 : Vérifier les Variables d'Environnement MinIO

Assurez-vous que MinIO utilise les bonnes credentials :
```bash
# Docker
docker exec <container_minio> env | grep MINIO

# Doit afficher :
# MINIO_ROOT_USER=moez@ght
# MINIO_ROOT_PASSWORD=12547?ghT
```

### Solution 4 : Tester MinIO Directement (Sans Nginx)

**Tester** si MinIO répond directement :
```bash
# Depuis le serveur
curl -I http://127.0.0.1:9000

# Depuis l'extérieur (si le port est exposé)
curl -I http://51.75.73.102:9000
```

Si MinIO répond directement mais pas via Nginx, le problème est dans la configuration Nginx.

## 📋 Checklist de Vérification

Avant de contacter le support, vérifiez :

- [ ] MinIO est démarré (`ps aux | grep minio` ou `docker ps`)
- [ ] MinIO écoute sur le port 9000 (`netstat -tlnp | grep 9000`)
- [ ] MinIO répond directement (`curl -I http://127.0.0.1:9000`)
- [ ] Configuration Nginx pointe vers le bon port/host
- [ ] Nginx peut se connecter à MinIO (pas de firewall qui bloque)
- [ ] Les logs Nginx ne montrent pas d'erreurs de connexion
- [ ] Les certificats SSL sont valides
- [ ] Le bucket `fitnessapp` existe dans MinIO

## 🚀 Test Après Correction

Une fois le problème résolu, testez :

```bash
# Test de connexion
curl -I https://s3.minio.51.75.73.102.nip.io:443

# Résultat attendu :
# HTTP/1.1 200 OK
# ou
# HTTP/1.1 403 Forbidden (normal si pas d'authentification)
```

## 📞 Support

Si le problème persiste après ces vérifications :

1. **Collecter les logs** :
   ```bash
   # Logs MinIO
   docker logs <container_minio> > minio.log
   
   # Logs Nginx
   sudo tail -100 /var/log/nginx/error.log > nginx_error.log
   ```

2. **Vérifier la configuration** :
   - Configuration Nginx complète
   - Variables d'environnement MinIO
   - Ports ouverts (firewall)

3. **Informations système** :
   - OS du serveur
   - Version de MinIO
   - Version de Nginx
   - Méthode d'installation (Docker, binary, etc.)

## ✅ Une Fois Résolu

Une fois que MinIO répond correctement, l'upload d'images dans l'app Flutter devrait fonctionner automatiquement. Les messages d'erreur améliorés dans l'app vous aideront à diagnostiquer d'autres problèmes éventuels.

