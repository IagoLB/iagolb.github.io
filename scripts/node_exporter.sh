#!/bin/bash
#Autor: Iago López Brañas
#Utilidad: Instalacón de node_exporter
if [ $(id -u) -ne 0 ]; then
    error "El script debe ser ejecutado como root."
	exit 1
fi

if [ ! id -u node_exporter > /dev/null 2>&1 ];then
	echo "Creando usuario para node_exporter"
	useradd --no-create-home --shell /bin/false node_exporter

	read -p "Presiona intro para continuar"
fi

hash_node_exporter_service_1_7_0=893dfb5a459feb6416d84b332b6691cc0ff01f307a37487375df369b660590b7
hash_actual=$(sha256sum /etc/systemd/system/node_exporter.service | awk -F " " '{print $1}' )
if [ $hash_node_exporter_service_1_7_0 != $hash_actual ];then
    cd /tmp
    curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
    tar xvf node_exporter-1.7.0.linux-amd64.tar.gz
    sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin
    sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
    rm -rf node_exporter-1.7.0.linux-amd64.tar.gz node_exporter-1.7.0.linux-amd64
fi

if [ ! -f /etc/systemd/system/node_exporter.service ];then
    printf"
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter 

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/node_exporter.service

    systemctl daemon-reload
    systemctl start node_exporter
    systemctl status node_exporter
    systemctl enable node_exporter
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