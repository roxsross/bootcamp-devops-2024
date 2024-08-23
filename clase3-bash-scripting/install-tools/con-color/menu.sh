#!/bin/bash

# Importar colores
source ./colors.sh

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

optMenu(){

    optNginx=$(echo -ne "RoxsOps based on ${GREEN}Nginx${RESET}")
    optApache=$(echo -ne "RoxsOps based on ${SORANGE}Apache${RESET}")
    optExit=$(echo -ne "Exit from ${SPURPLE}RoxsOps${RESET}")
    PS3="Select your Web Server: "

    select roxsOpt in "${optNginx}" "${optApache}" "${optExit}"
    do
        case $roxsOpt in
            "${optNginx}")
                chmod +x nginx.sh
                ./nginx.sh 
                break;;
            "${optApache}")
            chmod +x apache.sh
            ./apache.sh 
            break;;
            "${optExit}")
            echo -e "${green}${bold}\n[MESSAGE] : Good Bye! Thank you for using RoxsOps AUTO INSTALLER.\n${reset}"
            break;;
            *)
            echo -e "${red}${bold}\n[ERROR] : Oops!! Your selection does not match the above options. try again!!\n${reset}"
        esac
    done

}

banner
optMenu