#!/bin/bash
#Autor: Iago López Brañas
#Utilidad: Instalación de prometeus
if [ $(id -u) -ne 0 ]; then
    error "El script debe ser ejecutado como root."
	exit 1
fi

if [ ! id -u prometheus > /dev/null 2>&1 ];then
	echo "Creando usuario para prometheus"
	useradd -M -s /bin/false prometheus
	read -p "Presiona intro para continuar"
fi


echo "Descargando versión 2.51.1 de prometheus"
if [ ! $(systemctl is-active --quiet prometheus) ]; then
	cd /tmp
	wget https://github.com/prometheus/prometheus/releases/download/v2.51.1/prometheus-2.51.1.linux-amd64.tar.gz
	tar -xf prometheus-2.51.1.linux-amd64.tar.gz 	
	read -p "Presiona intro para continuar"
else
	echo "Ya está instalado"
fi


echo "Creando directorios para prometheus, y cambiando propietario a prometheus:prometheus"
read -p "Presiona intro para continuar"

if [ ! -d "/etc/prometheus" ]; then
	mkdir /etc/prometheus
fi

if [ ! -d "/var/lib/prometheus" ]; then
	mkdir /var/lib/prometheus
fi

chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

echo "Instalando prometheus"

if cp prometheus-2.51.1.linux-amd64/prometheus /usr/local/bin/ && cp prometheus-2.51.1.linux-amd64/promtool /usr/local/bin/ && \
    chown prometheus:prometheus /usr/local/bin/prometheus && chown prometheus:prometheus /usr/local/bin/promtool; then
    echo "Prometheus y promtool copiados correctamente y propietario cambiado."
else
    echo "Error al copiar Prometheus y/o promtool o al cambiar el propietario."
fi

# Copia de consoles y console_libraries a /etc/prometheus/ y cambio de propietario
if cp -r prometheus-2.51.1.linux-amd64/consoles /etc/prometheus && cp -r prometheus-2.51.1.linux-amd64/console_libraries /etc/prometheus && \
    chown -R prometheus:prometheus /etc/prometheus/consoles && chown -R prometheus:prometheus /etc/prometheus/console_libraries; then
    echo "Consoles y console_libraries copiados correctamente y propietario cambiado."
else
    echo "Error al copiar consoles y/o console_libraries o al cambiar el propietario."
fi

# Eliminación de archivos temporales
if rm -rf /tmp/prometheus-2.51.1.linux-amd64.tar.gz /tmp/prometheus-2.51.1.linux-amd64; then
    echo "Archivos temporales eliminados correctamente."
else
    echo "Error al eliminar archivos temporales."
fi


if [ ! -f /etc/prometheus/prometheus.yml ];then
	printf "
	global:
	scrape_interval: 15s
	scrape_configs:
	- job_name: 'prometheus'
		scrape_interval: 5s
		static_configs:
		- targets: ['localhost:9090']
	" > etc/prometheus/prometheus.yml

	chown prometheus:prometheus /etc/prometheus/prometheus.yml
fi


if [ ! -f /etc/systemd/system/prometheus.service ];then
	printf "
	[Unit]
	Description=Prometheus
	Wants=network-online.target
	After=network-online.target

	[Service]
	User=prometheus
	Group=prometheus
	Type=simple
	ExecStart=/usr/local/bin/prometheus \
		--config.file /etc/prometheus/prometheus.yml \
		--storage.tsdb.path /var/lib/prometheus/ \
		--web.console.templates=/etc/prometheus/consoles \
		--web.console.libraries=/etc/prometheus/console_libraries	

	[Install]
	WantedBy=multi-user.target
	" > /etc/systemd/system/prometheus.service
fi

if [ -f /etc/systemd/system/prometheus.service ];then
	systemctl daemon-reload
	systemctl start prometheus
	systemctl enable prometheus
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
