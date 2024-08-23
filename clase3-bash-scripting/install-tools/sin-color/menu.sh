#!/bin/bash


banner() {
    clear
    echo -e "
  _ __ ___  __  _____    
| '__/ _ \  \ \/ / __|  
| | | (_) | >  <\__ \. 
|_|  \___/  /_/\_\___/. v1.0#devops by @roxsross
RoxsOps 🔥 Automated installer\n\n"
}

optMenu(){

    optNginx=$(echo -ne "App based on Nginx")
    optApache=$(echo -ne "App based on Apache")
    optExit=$(echo -ne "Exit from RoxsOps")
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
            echo -e "[MESSAGE] : Good Bye! Thank you for using RoxsOps AUTO INSTALLER.\n"
            break;;
            *)
            echo -e "[ERROR] : Oops!! Your selection does not match the above options. try again!!\n"
        esac
    done

}

banner
optMenu