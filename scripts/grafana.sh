#!/bin/bash
#Autor: Iago López Brañas
#Utilidad: Instalación de grafana
if [ $(id -u) -ne 0 ]; then
    error "El script debe ser ejecutado como root."
	exit 1
fi

apt update
apt install -y software-properties-common wget apt-transport-https 

#Verificar si tenemos el repositorio
if ! grep "grafana" /etc/apt/sources.list /etc/apt/sources.list.d/*; then    
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    apt update && apt install -y grafana 
fi

#Habilitar los servicios si grafana se instalo correctamente
if dpkg -l | grep -q grafana; then
    # Habilitar el servicio Grafana si no está habilitado
    if ! systemctl is-enabled --quiet grafana-server; then
        systemctl enable grafana-server
    fi

    # Iniciar el servicio Grafana si no está iniciado
    if ! systemctl is-active --quiet grafana-server; then
        systemctl start grafana-server
    fi

    # Verificar el estado del servicio Grafana
    systemctl status grafana-server
else
    echo "No se pudo habilitar el servicio Grafana porque Grafana no está instalado."
    exit 1
fi

read -p "Instalación finalizada"
printf "
Gracias por instalar conmigo
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⠀⣠⣄⣼⣿⠻⢿⣷⡄⠀⠀
⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣨⣿⣿⣿⣶⣾⡏⠰⠆⠀
⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠛⠋⡀⠀⠀
⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⢻⣿⣿⣿⣿⣿⠟⠀⠀⠀⠸⠁⠀⠀
⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢀⣾⡿⠿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢠⣤⡈⠛⢿⣿⣿⣿⣿⣿⣥⣀⡉⠁⠀⠀⠘⢿⣧⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢀⣾⣿⣿⣦⡀⠙⠛⠿⠿⢿⣿⣿⣿⣿⡶⠀⠀⠈⠻⢿⣿⠆⠀⠀⠀⠀⠀
⠀⠀⣼⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢠⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠸⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠙⢿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠈⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀
"
sleep 5
exit 0
