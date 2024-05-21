#!/bin/bash

# verifica a conexao
check_connection() {
	if ping -c 1 google.com &> /dev/null; then
		return 0
	else
		return 1
	fi
}

loader() {
	(
	    while true; do
		zenity --progress --title="Atualizando Sistema" --text="Aguarde enquanto o sistema está sendo atualizado..." --no-cancel --ok-label="OK" --pulsate

		# Verifica se o arquivo de marcação foi criado
		if [ -f /tmp/upgrade_finished ]; then
		    break
		fi

		# Aguarda antes de verificar novamente
		sleep 0.2
	    done
	)
}

if check_connection; then
	# variavel de controle anti-falha de execucao
	correct_passwrd=false
	# verificacao de senha
	while ! $correct_passwrd; do
	    passwrd="$(zenity --password --title "CHECK PASSWORD" --text "Confirme a senha da máquina.")"
	    if [ -n "$passwrd" ]; then
		if echo "$passwrd" | sudo -S true >/dev/null 2>&1; then
		    correct_passwrd=true
		else
		    zenity --error --text="Senha incorreta. Tente novamente." --width=150
		fi
	    else
		exit
	    fi
	done
	# configura o ambiente
	gsettings set org.gnome.desktop.session idle-delay 0
	gsettings set org.gnome.desktop.screensaver lock-enabled false
	gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false
	gsettings set org.gnome.desktop.notifications show-banners false
	gsettings set org.gnome.shell favorite-apps "[]"
	# atualiza o sistema
	echo "$passwrd" | sudo -S apt-get update -y && sudo apt update && sudo apt upgrade -y && sudo apt-get update && sudo apt-get upgrade -y && sudo snap refresh && sudo apt-get dist-upgrade && sudo apt autoremove -y
	# instala e configura timezone
	sudo apt-get install ntp ntpdate -y
	sudo service ntp stop
	sudo ntpdate a.ntp.br
	sudo service ntp start
	sudo timedatectl set-timezone America/Sao_Paulo
	# instala o SAMBA
	sudo apt install samba -y
	# instala o Asterisk
	sudo apt-get install asterisk -y
	# instala o xrdp
	sudo apt install xrdp -y && echo “xfce4-session” | tee .xsession && sudo systemctl restart xrdp
	# instala e configura o mysql
	echo "$psswrd" | sudo -S apt-get install -y openssh-server build-essential mysql-client libssl-dev libmysqlclient-dev libmysql++-dev libmysqlcppconn-dev libqt5sql5-mysql mysql-server libproj15 libzip5 libavdevice58 libavresample4
	sudo systemctl enable ssh
	sudo systemctl start ssh
	cd /home/$USER/xubuntu-heads-main/
	gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/xubuntu-heads-main/bg.png"
	gsettings set org.gnome.desktop.screensaver picture-uri "file:///home/$USER/xubuntu-heads-main/bg.png"
	echo "$psswrd" | sudo -S chmod +x ./resources.sql
	sudo dpkg -i ./mysql-workbench-community_8.0.27-1ubuntu20.04_amd64.deb
	sudo apt-get install -y ./mysql-workbench-community_8.0.27-1ubuntu20.04_amd64.deb
	sudo apt --fix-broken install -y
	sudo snap connect mysql-workbench-community:password-manager-service :password-manager-service
	sudo mysql < /home/$USER/xubuntu-heads-main/resources.sql
	# Habilita o acesso remoto no servidor
	sudo ufw allow ssh
	sudo ufw allow 3306
	echo 'bind-address = 0.0.0.0' >> /etc/mysql/mysql.conf.d/mysqld.cnf && sudo systemctl restart mysql
else
	zenity --error --title "VERIFIQUE SUA CONEXÃO" --text "Conecte-se a uma rede externa." --width=200
fi
