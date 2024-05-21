#!/bin/bash

# impede que a tela seja bloqueada
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false
# configura o ambiente para iniciar o instalador depois de baixar o ubuntu-server 
sudo chmod +x ~/xubuntu-heads-main/install.sh && ~/xubuntu-heads-main/install.sh
sudo mkdir /home/$USER/.config/autostart/
sudo cp ~/xubuntu-heads-main/xubuntu.desktop /home/$USER/.config/autostart/
sudo chmod +x /home/$USER/.config/autostart/xubuntu.desktop
# instala o ubuntu-server
echo "gdm3 shared/default-x-display-manager select gdm3" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y xubuntu-desktop
sudo reboot
