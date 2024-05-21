#!/bin/bash

# impede que a tela seja bloqueada
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false
# atualiza o sistema
sudo apt update && sudo apt upgrade -y && sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade && sudo apt autoremove -y && sudo apt-get autoremove -y && sudo snap refresh && sudo fwupdmgr refresh && sudo fwupdmgr get-updates -y && sudo fwupdmgr update
# instala o ubuntu-server
echo "gdm3 shared/default-x-display-manager select gdm3" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y xubuntu-desktop
# configura o ambiente para iniciar o instalador depois de baixar o ubuntu-server 
sudo chmod +x ~/xubuntu-heads-main/install.sh
mkdir /home/$USER/.config/autostart/
cp ~/xubuntu-heads-main/xubuntu.desktop /home/$USER/.config/autostart/
sudo chmod +x /home/$USER/.config/autostart/xubuntu.desktop
sudo reboot
