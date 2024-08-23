#! /bin/bash

# Importar colores
source ./colors.sh

TIME=$(date +'%H:%M:%S')

banner() {
    clear
    echo -e "
${GREEN}            ${SPURPLE}             ${RESET}
${GREEN}  _ __ ___  ${SPURPLE}__  _____    ${RESET}
${GREEN} | '__/ _ \ ${SPURPLE} \ \/ / __|  ${RESET}
${GREEN} | | | (_) |${SPURPLE}  >  <\__ \. ${RESET}
${GREEN} |_|  \___/ ${SPURPLE} /_/\_\___/. ${RESET}v{1.0#${YELLOW}devops${RESET}} by @roxsross
${SPURPLE}RoxsOps${RESET} Automated installer\n\n"
}

checkPrivileges(){

    echo "[*] start at $(date)"
    echo -e "[*] ${GREEN}RoxsOps${RESET} - ${SPURPLE}SuperPower Edition${RESET} \n\n"
    echo -e "[${LBLUE}${TIME}${RESET}] [${YELLOW}WARNING${RESET}] Make sure you install the ${GREEN}RoxsOps${RESET} on a clean server${reset}"

    if [ "$EUID" -ne 0 ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${RED}ERROR${RESET}] Oops! You must run this tools using root/superuser privileges."
    exit
    fi

}

checkOS_package() {

    echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Checking OS for Compability"
    if [[ ${OSTYPE} == "linux-gnu" ]]; then
        if [[ "$(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2 | awk '{print $1;}')" =~ ^(Ubuntu|Debian)$ ]]; then
            if command -v nginx &> /dev/null; then
                echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Nginx${RESET} is already installed"
            else
                echo -e "[${LBLUE}${TIME}${RESET}] [${RED}ERROR${RESET}] ${RED}Nginx${RESET} is not installed, trying to install..."
                echo -ne "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Updating repository ------->> "
                `sudo apt -qq -y update &> /dev/null` #Updating repository with silent options
                wait
                echo -e "[${GREEN}DONE${RESET}]"
                echo -ne "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Installing Nginx ------->> "
                `sudo apt install nginx -y -qq &> /dev/null`
                echo -e "[${GREEN}DONE${RESET}]"
                if  ! dpkg -l | grep -q nginx; then
                    echo -e "[${LBLUE}${TIME}${RESET}] [${RED}ERROR${RESET}] Failed to install Nginx, check manually required."
                fi
            fi
                    
        else
            echo -e "[${LBLUE}${TIME}${RESET}] [${LRED}ERROR${RESET}] OS not compatible, Your Operating System is ${GREEN}${OSTYPE}${RESET}"
            echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Supported OS ${GREEN}Debian${RESET} or ${GREEN}Ubuntu${RESET} (linux-gnu)"
            exit
        fi
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${LRED}ERROR${RESET}] OS not compatible, Your Operating System is ${GREEN}${OSTYPE}${RESET}"
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Supported OS ${GREEN}Debian${RESET} or ${GREEN}Ubuntu${RESET} (linux-gnu)"
        exit
    fi

}

checkService(){

    echo -ne "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Enabling Nginx service ------->> "
    `systemctl enable nginx &>/dev/null && systemctl restart nginx &>/dev/null`
    wait
    echo -e "[${GREEN}DONE${RESET}]"
    echo -ne "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Nginx service status ------->> "
    if [[ $(systemctl is-active nginx) == "active" ]]; then
        echo -e "[${GREEN}ACTIVE${RESET}]"
    else
        echo -e "[${LRED}ERROR${RESET}]"
        echo -e "[${LBLUE}${TIME}${RESET}] [${RED}ERROR${RESET}] Failed to start Nginx, check manually required"
    fi
    echo "[*] ended at $(date)"
}


banner
checkPrivileges
checkOS_package
checkService
exit