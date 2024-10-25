#!/bin/bash
set -e

# Debug - Mostrar variables (comentar en producción)
echo "Checking environment variables..."
echo "BOT_URL: ${BOT_URL:0:20}..." # Solo mostrar los primeros 20 caracteres por seguridad
echo "TELEGRAM_CHAT_ID: $TELEGRAM_CHAT_ID"
echo "GITHUB_REPOSITORY: $GITHUB_REPOSITORY"
echo "GITHUB_REF: $GITHUB_REF"
echo "GITHUB_ACTOR: $GITHUB_ACTOR"

# Verificar variables requeridas
if [ -z "$BOT_URL" ]; then
    echo "Error: BOT_URL no está definida"
    exit 1
fi

if [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Error: TELEGRAM_CHAT_ID no está definida"
    exit 1
fi

# Función principal de notificación
send_telegram_notification() {
    local status=$1
    local version=$2
    local commit_sha=$3
    local build_date=$4

    echo "Preparing notification for status: $status"
    echo "Version: $version"
    echo "Commit SHA: $commit_sha"
    echo "Build Date: $build_date"

    if [ -z "$status" ] || [ -z "$version" ] || [ -z "$commit_sha" ]; then
        echo "Error: Faltan argumentos requeridos"
        echo "Uso: $0 <status> <version> <commit_sha> <build_date>"
        exit 1
    fi

    case $status in
        "start")
            MESSAGE="🚀 *Nuevo Despliegue Iniciado*
            
            📦 *Proyecto:* ${GITHUB_REPOSITORY}
            🔄 *Branch:* ${GITHUB_REF#refs/heads/}
            🏷️ *Version:* ${version}
            🔨 *Commit:* \`${commit_sha}\`
            ⏰ *Inicio:* $(date +"%Y-%m-%d %H:%M:%S")
            👨‍💻 *Autor:* ${GITHUB_ACTOR}
            
            📝 *Etapas Completadas:*
            ✅ Code Quality Check
            ✅ Unit Tests
            ✅ Security Audit
            ✅ SonarCloud Analysis
            
            ⚡️ *Estado:* Deployment en progreso..."
            ;;
            
        "success")
            MESSAGE="✅ *Despliegue Exitoso*
            
            📦 *Proyecto:* ${GITHUB_REPOSITORY}
            🔄 *Branch:* ${GITHUB_REF#refs/heads/}
            🏷️ *Version:* ${version}
            🔨 *Commit:* \`${commit_sha}\`
            ⏰ *Fin:* $(date +"%Y-%m-%d %H:%M:%S")
            👨‍💻 *Autor:* ${GITHUB_ACTOR}
            
            📝 *Detalles:*
            🐳 *Imagen:* \`${REGISTRY}/${REPOSITORY}:${version}\`
            📅 *Build Date:* ${build_date}
            
            🎉 *Estado:* ¡Deployment completado con éxito!"
            ;;
            
        "failure")
            MESSAGE="❌ *Despliegue Fallido*
            
            📦 *Proyecto:* ${GITHUB_REPOSITORY}
            🔄 *Branch:* ${GITHUB_REF#refs/heads/}
            🏷️ *Version:* ${version}
            🔨 *Commit:* \`${commit_sha}\`
            👨‍💻 *Autor:* ${GITHUB_ACTOR}
            
            ⚠️ *Posibles causas:*
            - Fallos en las pruebas unitarias
            - Problemas de seguridad detectados
            - Error en el build de Docker
            - Error en el despliegue a Kubernetes
            
            🚨 *Estado:* El deployment ha fallado
            
            Por favor, revisa los logs para más detalles."
            ;;
        *)
            echo "Error: Estado no válido. Debe ser 'start', 'success' o 'failure'"
            exit 1
            ;;
    esac

    echo "Sending notification to Telegram..."
    
    # Debug - Mostrar el comando curl (sin el mensaje completo)
    echo "curl -s -X POST ${BOT_URL} -d chat_id=${TELEGRAM_CHAT_ID} [...mensaje omitido...] -d parse_mode=Markdown"

    # Enviar la notificación
    curl -s -X POST "${BOT_URL}" \
        -d chat_id="${TELEGRAM_CHAT_ID}" \
        -d text="${MESSAGE}" \
        -d parse_mode=Markdown || {
        echo "Error al enviar la notificación a Telegram"
        exit 1
    }

    echo "Notificación enviada correctamente"
}

# Ejecutar la función con los argumentos recibidos
send_telegram_notification "$@"