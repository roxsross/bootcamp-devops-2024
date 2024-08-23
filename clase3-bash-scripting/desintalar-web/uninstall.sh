#!/bin/bash

# Función para desinstalar Apache
uninstall_apache() {
    echo "Desinstalando Apache..."
    sudo systemctl stop apache2
    sudo apt-get remove --purge apache2 apache2-utils apache2-bin apache2.2-common -y
    sudo apt-get autoremove -y
    sudo apt-get autoclean
    sudo rm -rf /etc/apache2 /var/www/html
    echo "Apache ha sido desinstalado."
}

# Función para desinstalar Nginx
uninstall_nginx() {
    echo "Desinstalando Nginx..."
    sudo systemctl stop nginx
    sudo apt-get remove --purge nginx nginx-common nginx-full -y
    sudo apt-get autoremove -y
    sudo apt-get autoclean
    sudo rm -rf /etc/nginx /var/www/html
    echo "Nginx ha sido desinstalado."
}

# Función para mostrar el menú
show_menu() {
    echo "Seleccione una opción:"
    echo "1) Desinstalar Apache"
    echo "2) Desinstalar Nginx"
    echo "3) Desinstalar ambos (Apache y Nginx)"
    echo "4) Salir"
}

# Función principal que ejecuta el menú
main() {
    while true; do
        show_menu
        read -p "Ingrese su elección [1-4]: " choice
        case $choice in
            1)
                uninstall_apache
                ;;
            2)
                uninstall_nginx
                ;;
            3)
                uninstall_apache
                uninstall_nginx
                ;;
            4)
                echo "Saliendo..."
                exit 0
                ;;
            *)
                echo "Opción no válida. Intente nuevamente."
                ;;
        esac
        echo ""
    done
}

# Ejecuta la función principal
main
