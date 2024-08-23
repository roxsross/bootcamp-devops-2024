#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ser ejecutado con privilegios de sudo o como root."
  exit 1
fi

LOG_FILE="/var/log/jenkins_installation.log"
exec &> >(tee -a "$LOG_FILE")

echo "# $(date) Installation is starting."

echo "# $(date) Install Jenkins key and package configuration..."
wget -q -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "# $(date) Install Java 17, NGINX, and Jenkins..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -qq \
    openjdk-17-jre \
    nginx \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    jenkins 

echo "# $(date) Configure Jenkins..."
chown -R jenkins:jenkins /var/lib/jenkins/plugins

echo "# $(date) Configure NGINX..."
unlink /etc/nginx/sites-enabled/default

cat <<EOF | tee /etc/nginx/conf.d/jenkins.conf > /dev/null
upstream jenkins {
    server 127.0.0.1:8080;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    location / {
        proxy_pass http://jenkins;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

echo "# $(date) Reload NGINX to pick up the new configuration..."
systemctl reload nginx

echo "# $(date) Restart Jenkins..."
systemctl restart jenkins

clear
echo "Installation is complete."

echo "# Open the URL for this server in a browser and log in with the following credentials:"
echo
echo "    Username: admin"
echo "    Password: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
echo
