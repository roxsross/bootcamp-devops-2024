#!/bin/bash

# Definir colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sin color

# Función para imprimir mensajes con formato
log() {
    local level=$1
    local message=$2
    case $level in
        "INFO") echo -e "${GREEN}[INFO]${NC} $message" ;;
        "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

# Función para verificar y manejar errores
check_error() {
    if [ $? -ne 0 ]; then
        log "ERROR" "$1"
        exit 1
    fi
}

# Verificar si el script se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    log "ERROR" "Este script debe ejecutarse con privilegios de root."
    exit 1
fi

# Paquetes a instalar
packages=("apache2" "git")

# Función para instalar paquetes
install_package() {
    local package=$1
    if ! dpkg -l "$package" > /dev/null 2>&1; then
        log "INFO" "Instalando $package..."
        apt-get update -qq && apt-get install -y "$package" > /dev/null 2>&1
        check_error "Error al instalar $package."
        log "INFO" "$package instalado correctamente."
    else
        log "INFO" "$package ya está instalado."
    fi
}

# Instalar paquetes
for package in "${packages[@]}"; do
    install_package "$package"
done

# Deshabilitar el sitio predeterminado
a2dissite 000-default > /dev/null 2>&1
check_error "Error al deshabilitar el sitio predeterminado."

# Configurar el repositorio
repo_directory="/var/www/html/startbootstrap"
repo_url="https://gitlab.com/training-devops-cf/startbootstrap.git"

if [ -d "$repo_directory" ]; then
    log "INFO" "Actualizando el repositorio existente..."
    cd "$repo_directory" || exit
    git pull > /dev/null 2>&1
    check_error "Error al actualizar el repositorio."
else
    log "INFO" "Clonando el repositorio..."
    git clone "$repo_url" "$repo_directory" > /dev/null 2>&1
    check_error "Error al clonar el repositorio."
fi

# Ajustar permisos y propietario
chown -R www-data:www-data "$repo_directory"
chmod -R 755 "$repo_directory"

# Configurar Apache
cat <<EOF > /etc/apache2/sites-available/startbootstrap.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $repo_directory

    <Directory $repo_directory>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Habilitar el sitio de Apache
a2ensite startbootstrap > /dev/null 2>&1
check_error "Error al habilitar el sitio de Apache."

# Reiniciar Apache
systemctl restart apache2
check_error "Error al reiniciar Apache."

# Agregar la excepción a nivel global para Git
git config --global --add safe.directory "$repo_directory"
check_error "Error al configurar Git."

log "INFO" "Configuración completada. El repositorio está disponible en http://localhost/startbootstrap"