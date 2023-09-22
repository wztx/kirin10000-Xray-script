#!/bin/bash

clear

show_main_menu() {
while true; do
clear
echo "#################################################################"
echo "(script-xanmod-unofficial-installer) >> (sep 2023)"
echo "#################################################################"
echo " ██   ██ ███████ ██████  ███    ██ ███████ ██     " 
echo " ██  ██  ██      ██   ██ ████   ██ ██      ██     " 
echo " █████   █████   ██████  ██ ██  ██ █████   ██     " 
echo " ██  ██  ██      ██   ██ ██  ██ ██ ██      ██     " 
echo " ██   ██ ███████ ██   ██ ██   ████ ███████ ███████"
echo "#################################################################"
echo "(build-latest) >> (0.0.3)"     
echo "(script-xanmod-installer-unofficial-gitlab) >> (https://gitlab.com/manoel-linux1/script-xanmod-installer-unofficial)"
echo "#################################################################"

if [[ $EUID -ne 0 ]]; then
echo " ███████ ██████  ██████   ██████  ██████  ██ "
echo " ██      ██   ██ ██   ██ ██    ██ ██   ██ ██ "
echo " █████   ██████  ██████  ██    ██ ██████  ██ "
echo " ██      ██   ██ ██   ██ ██    ██ ██   ██    "
echo " ███████ ██   ██ ██   ██  ██████  ██   ██ ██ "                                                                                        
echo "#################################################################"
echo "(Superuser privileges or sudo required to execute the script)" 
echo "#################################################################"
exit 1
fi

sudo apt-get update
sudo apt-get install --no-install-recommends inetutils-ping -y
echo "#################################################################"

clear

echo "#################################################################"
echo "(1)> (Install) >> (the linux-xanmod-x64v1 all-x86-64-CPUs)"
echo "(2)> (Install) >> (the linux-xanmod-lts-x64v1 all-x86-64-CPUs)"
echo "(3)> (Exit)"
echo "#################################################################"

read -p "(Enter your choice) >> " choice
echo "#################################################################"

case $choice in
1)
show_linux-xanmod-x64v1
;;
2)
show_linux-xanmod-lts-x64v1
;;
3)
exit 0
;;
*)
echo "(Invalid choice. Please try again)"
echo "#################################################################"
sleep 2
;;
esac
done
}

show_linux-xanmod-x64v1() {
while true; do
clear
if [ ! -x /bin/apt ]; then
echo "#################################################################"
echo "(Warning) >> (You are trying to run a version meant for another distribution) 
(To prevent issues, the script has blocked a warning to execute the version meant for your distribution)"
echo "#################################################################"
exit 1
fi
echo "#################################################################"
read -p "(This action may have unintended consequences. Are you sure you want to continue) (y/n) >> " second_confirm
echo "#################################################################"
if [[ "$second_confirm" == "y" || "$second_confirm" == "Y" ]]; then
read -p "(Warning) >> (This script is provided 'AS IS', without any warranties of any kind. The user assumes full responsibility for executing this script and any resulting consequences. We recommend backing up your data before proceeding. If the script does not cause any apparent issues, you can use the PC normally. Are you sure you want to proceed) (y/n) >> " third_confirm
echo "#################################################################"
if [[ "$third_confirm" == "y" || "$third_confirm" == "Y" ]]; then
echo "(Proceeding with the changes)"
else
echo "(Action canceled by the user)"
echo "#################################################################"
exit 1
fi
else
echo "(Action canceled by the user)"
echo "#################################################################"
exit 1
fi
echo "#################################################################"
echo "(Checking for updates in Ubuntu/Debian)" 
echo "#################################################################"
sudo apt-get update
sudo apt-get install --no-install-recommends gpg unzip binutils tar curl xz-utils grep gawk sed -y
clear
echo "#################################################################"

read -p "(Do you want to update your system) (y/n) >> " choice
echo "#################################################################"
if [[ $choice == "y" || $choice == "Y" ]]; then
curl -fSsL https://dl.xanmod.org/archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/xanmod-archive-keyring.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install --no-install-recommends linux-xanmod-x64v1 -y
sudo apt-get autoremove -y 
sudo apt-get autoclean -y
else
echo "(Skipping system update)"
echo "#################################################################"
curl -fSsL https://dl.xanmod.org/archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/xanmod-archive-keyring.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list
sudo apt-get update
sudo apt-get install --no-install-recommends linux-xanmod-x64v1 -y
sudo apt-get autoremove -y 
sudo apt-get autoclean -y
clear
fi

clear

echo "#################################################################"
echo " ██████   ██████  ███    ██ ███████ ██ "
echo " ██   ██ ██    ██ ████   ██ ██      ██ "
echo " ██   ██ ██    ██ ██ ██  ██ █████   ██ "
echo " ██   ██ ██    ██ ██  ██ ██ ██         "
echo " ██████   ██████  ██   ████ ███████ ██ "  
echo "#################################################################"
echo "(Installation completed)"
echo "#################################################################"
echo "(To update Xanmod, use the following command >> sudo apt-get update && sudo apt-get upgrade)"
echo "#################################################################"  
echo "(Attention) >> (You need to execute the script upon restarting the machine to remove the old kernel without conflicts)
(You must first check if Ubuntu/Debian is running the Xanmod kernel)
(Then, proceed to remove all other kernels and keep only the Xanmod. Give remove-kernel.sh executable permissions using chmod a+x remove-kernel.sh) 
(and then use sudo ./remove-kernel.sh. I am not responsible for any damages to the system. Use it at your own risk)"
echo "#################################################################"  
read -p "(To apply the changes, you need to restart system) (y/n) >> " confirm
                
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
echo "#################################################################"
echo "(Restarting the system)"    
echo "#################################################################"
sudo reboot
else
echo "#################################################################"
echo "(Restart canceled)"
echo "#################################################################"
fi
read -rsn1 -p "(press Enter to return to the main menu)
#################################################################" key
if [[ $key == "r" || $key == "R" ]]; then
continue
fi

break
done

echo "#################################################################"
}

show_linux-xanmod-lts-x64v1() {
while true; do
clear
if [ ! -x /bin/apt ]; then
echo "#################################################################"
echo "(Warning) >> (You are trying to run a version meant for another distribution) 
(To prevent issues, the script has blocked a warning to execute the version meant for your distribution)"
echo "#################################################################"
exit 1
fi
echo "#################################################################"
read -p "(This action may have unintended consequences. Are you sure you want to continue) (y/n) >> " second_confirm
echo "#################################################################"
if [[ "$second_confirm" == "y" || "$second_confirm" == "Y" ]]; then
read -p "(Warning) >> (This script is provided 'AS IS', without any warranties of any kind. The user assumes full responsibility for executing this script and any resulting consequences. We recommend backing up your data before proceeding. If the script does not cause any apparent issues, you can use the PC normally. Are you sure you want to proceed) (y/n) >> " third_confirm
echo "#################################################################"
if [[ "$third_confirm" == "y" || "$third_confirm" == "Y" ]]; then
echo "(Proceeding with the changes)"
else
echo "(Action canceled by the user)"
echo "#################################################################"
exit 1
fi
else
echo "(Action canceled by the user)"
echo "#################################################################"
exit 1
fi
echo "#################################################################"
echo "(Checking for updates in Ubuntu/Debian)" 
echo "#################################################################"
sudo apt-get update
sudo apt-get install --no-install-recommends gpg unzip binutils tar curl xz-utils grep gawk sed -y
clear
echo "#################################################################"

read -p "(Do you want to update your system) (y/n) >> " choice
echo "#################################################################"
if [[ $choice == "y" || $choice == "Y" ]]; then
curl -fSsL https://dl.xanmod.org/archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/xanmod-archive-keyring.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install --no-install-recommends linux-xanmod-lts-x64v1 -y
sudo apt-get autoremove -y 
sudo apt-get autoclean -y
else
echo "(Skipping system update)"
echo "#################################################################"
curl -fSsL https://dl.xanmod.org/archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/xanmod-archive-keyring.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list
sudo apt-get update
sudo apt-get install --no-install-recommends linux-xanmod-lts-x64v1 -y
sudo apt-get autoremove -y 
sudo apt-get autoclean -y
clear
fi

clear

echo "#################################################################"
echo " ██████   ██████  ███    ██ ███████ ██ "
echo " ██   ██ ██    ██ ████   ██ ██      ██ "
echo " ██   ██ ██    ██ ██ ██  ██ █████   ██ "
echo " ██   ██ ██    ██ ██  ██ ██ ██         "
echo " ██████   ██████  ██   ████ ███████ ██ "  
echo "#################################################################"
echo "(Installation completed)"
echo "#################################################################"
echo "(To update Xanmod, use the following command >> sudo apt-get update && sudo apt-get upgrade)"
echo "#################################################################"  
echo "(Attention) >> (You need to execute the script upon restarting the machine to remove the old kernel without conflicts)
(You must first check if Ubuntu/Debian is running the Xanmod kernel)
(Then, proceed to remove all other kernels and keep only the Xanmod. Give remove-kernel.sh executable permissions using chmod a+x remove-kernel.sh) 
(and then use sudo ./remove-kernel.sh. I am not responsible for any damages to the system. Use it at your own risk)"
echo "#################################################################"  
read -p "(To apply the changes, you need to restart system) (y/n) >> " confirm
                
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
echo "#################################################################"
echo "(Restarting the system)"    
echo "#################################################################"
sudo reboot
else
echo "#################################################################"
echo "(Restart canceled)"
echo "#################################################################"
fi
read -rsn1 -p "(press Enter to return to the main menu)
#################################################################" key
if [[ $key == "r" || $key == "R" ]]; then
continue
fi

break
done

echo "#################################################################"
}

show_main_menu