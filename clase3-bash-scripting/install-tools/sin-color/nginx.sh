#! /bin/bash


TIME=$(date +'%H:%M:%S')

banner() {
    clear
    echo -e "
  _ __ ___  __  _____    
| '__/ _ \  \ \/ / __|  
| | | (_) | >  <\__ \. 
|_|  \___/  /_/\_\___/. v1.0#devops by @roxsross
RoxsOps 🔥  Automated installer\n\n"
}

checkPrivileges(){

    echo "[*] start at $(date)"
    echo -e "[*]  RoxsOps  -  SuperPower Edition \n\n"
    echo -e "[ ${TIME} ] [ WARNING ] Make sure you install the  RoxsOps  on a clean server "

    if [ "$EUID" -ne 0 ]; then
        echo -e "[ ${TIME} ] [ ERROR ] Oops! You must run this tools using root/superuser privileges."
    exit
    fi

}

checkOS_package() {

    echo -e "[ ${TIME} ] [ INFO ] Checking OS for Compability"
    if [[ ${OSTYPE} == "linux-gnu" ]]; then
        if [[ "$(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2 | awk '{print $1;}')" =~ ^(Ubuntu|Debian)$ ]]; then
            if command -v nginx &> /dev/null; then
                echo -e "[ ${TIME} ] [ INFO ]  Nginx  is already installed"
            else
                echo -e "[ ${TIME} ] [ ERROR ]  Nginx  is not installed, trying to install..."
                echo -ne "[ ${TIME} ] [ INFO ] Updating repository ------->> "
                `sudo apt -qq -y update &> /dev/null` 
                wait
                echo -e "[ DONE ]"
                echo -ne "[ ${TIME} ] [ INFO ] Installing Nginx ------->> "
                `sudo apt install nginx -y -qq &> /dev/null`
                echo -e "[ DONE ]"
                if ! dpkg -l | grep -q nginx; then
                    echo -e "[ ${TIME} ] [ ERROR ] Nginx is not installed. Please check manually."
                fi
            fi
                    
        else
            echo -e "[ ${TIME} ] [ ERROR ] OS not compatible, Your Operating System is  ${OSTYPE} "
            echo -e "[ ${TIME} ] [ INFO ] Supported OS  Debian  or  Ubuntu  (linux-gnu)"
            exit
        fi
    else
        echo -e "[ ${TIME} ] [ ERROR ] OS not compatible, Your Operating System is  ${OSTYPE} "
        echo -e "[ ${TIME} ] [ INFO ] Supported OS  Debian  or  Ubuntu  (linux-gnu)"
        exit
    fi

}

checkService(){

    echo -ne "[ ${TIME} ] [ INFO ] Enabling Nginx service ------->> "
    `systemctl enable nginx &>/dev/null && systemctl restart nginx &>/dev/null`
    wait
    echo -e "[ DONE ]"
    echo -ne "[ ${TIME} ] [ INFO ] Nginx service status ------->> "
    if [[ $(systemctl is-active nginx) == "active" ]]; then
        echo -e "[ ACTIVE ]"
    else
        echo -e "[ ERROR ]"
        echo -e "[ ${TIME} ] [ ERROR ] Failed to start Nginx, check manually required"
    fi

    echo "[*] ended at $(date)"
}


banner
checkPrivileges
checkOS_package
checkService
exit