#!/bin/bash
set -euo pipefail

# Constants
readonly LOG_FILE="/tmp/notify-$(date +%Y%m%d-%H%M%S).log"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=5

# Logging function
log() {
    local level=$1
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Validate environment variables
check_required_vars() {
    local required_vars=("BOT_URL" "TELEGRAM_CHAT_ID" "GITHUB_REPOSITORY" "GITHUB_REF" "GITHUB_ACTOR")
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            log "ERROR" "Required variable $var is not set"
            exit 1
        fi
    done
}

# Format duration
format_duration() {
    local start_time=$1
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    local hours=$((duration / 3600))
    local minutes=$(( (duration % 3600) / 60 ))
    local seconds=$((duration % 60))
    
    echo "${hours}h ${minutes}m ${seconds}s"
}

# Send message to Telegram with retry mechanism
send_telegram_message() {
    local message=$1
    local retry_count=0
    local start_time=$(date +%s)
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        if curl -s -X POST "${BOT_URL}" \
            -d chat_id="${TELEGRAM_CHAT_ID}" \
            -d text="${message}" \
            -d parse_mode=Markdown; then
            log "INFO" "Message sent successfully"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        log "WARN" "Failed to send message, attempt ${retry_count}/${MAX_RETRIES}"
        
        if [ $retry_count -lt $MAX_RETRIES ]; then
            sleep $RETRY_DELAY
        fi
    done
    
    log "ERROR" "Failed to send message after ${MAX_RETRIES} attempts"
    return 1
}

# Main notification function
send_telegram_notification() {
    local status=$1
    local version=${2:-"Unknown"}
    local commit_sha=${3:-"Unknown"}
    local build_date=${4:-"Unknown"}
    local start_time=$(date +%s)
    
    log "INFO" "Preparing notification for status: $status"
    
    # Build status emoji
    local status_emoji
    case $status in
        "start") status_emoji="🚀" ;;
        "success") status_emoji="✅" ;;
        "failure") status_emoji="❌" ;;
        *) 
            log "ERROR" "Invalid status: $status"
            exit 1
        ;;
    esac
    
    # Build common message header
    local message="$status_emoji *${status^} Deployment Notification*

📦 *Project:* \`${GITHUB_REPOSITORY}\`
🔄 *Branch:* \`${GITHUB_REF#refs/heads/}\`
🏷️ *Version:* \`${version}\`
🔨 *Commit:* \`${commit_sha}\`
👤 *Author:* \`${GITHUB_ACTOR}\`
⏰ *Time:* \`$(date +"%Y-%m-%d %H:%M:%S UTC")\`"

    # Add status-specific content
    case $status in
        "start")
            message+="

🔍 *Pending Steps:*
▫️ Build Images
▫️ Deploy to K8s"
            ;;
        "success")
            message+="

✨ *Deployment Details:*
▫️ *Duration:* \`$(format_duration "$start_time")\`
▫️ *Build Date:* \`${build_date}\`
▫️ *Environment:* \`${GITHUB_EVENT_NAME}\`

🎉 Deployment completed successfully!"
            ;;
        "failure")
            message+="

❌ *Deployment Failed*
▫️ *Duration:* \`$(format_duration "$start_time")\`
▫️ *Build Date:* \`${build_date}\`

⚠️ Please check the GitHub Actions logs for details."
            ;;
    esac

    # Send notification
    if send_telegram_message "$message"; then
        log "INFO" "Notification sent successfully for status: $status"
    else
        log "ERROR" "Failed to send notification"
        exit 1
    fi
}

# Main execution
main() {
    log "INFO" "Starting notification script"
    
    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Check required variables
    check_required_vars
    
    # Execute notification
    if ! send_telegram_notification "$@"; then
        log "ERROR" "Notification failed"
        exit 1
    fi
    
    log "INFO" "Notification script completed successfully"
}

# Execute main function with all arguments
main "$@"