---
title: Instalación de paquetes
layout: default
parent: Preparación del servidor de monitorización
grand_parent: Preparación del escenario
nav_order: 1
has_children: false
has_toc: true
---
# Estructura de navegación
{: .no_toc }

<details open markdown="block">
  <summary>
    Tabla de contenidos
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>
# Preparando la base

Partiendo de un SO `Debian 12` recién instalado lo primero que haremos será actualizar los repositorios y los paquetes que tengamos con el comando:

```bash
apt update && apt upgrade
```

# Instalación de paquetes

Con el SO ya actualizado instalaremos los paquetes necesarios para realizar las instalaciones con el comando:

```bash
apt install wget apt-transport-https software-properties-common openssh-server apache2-utils sudo
```

La función de los paquetes instalados será la siguiente:
- **wget:** Descargar archivos de Internet desde la línea de comandos.
- **apt-transport-https:** Permite que apt use HTTPS para descargar paquetes de repositorios.
- **software-properties-common:** Proporciona herramientas para administrar repositorios de software.
- **sudo**: Permite ejecutar comandos con privilegios elevados, mejorando la seguridad y la gestión del sistema.
- **openssh-server:** Permite que el servidor reciba conexiones de otros sistemas mediante SSH, este paquete será utilizado para la administración del servidor.
- **apache2-utils:** Herramientas de línea de comandos para administrar Apache 2, este paquete será utilizado para la creación de contraseñas de autentificación más adelante.

# Creación de usuarios

Debemos asignar un usuario para ejecutar los servicios de Grafana, de Prometheus y de Influxdb, por seguridad crearemos usuarios con el shell `/bin/false` para que no se pueda iniciar sesión con esos usuarios. Grafana e Influxdb ya lo crean automáticamente en la instalación, sólo será necesario crear el usuario de Prometheus, el comando será el siguiente:

```bash
adduser --no-create-home --shell /bin/false prometheus
```

# Instalación de Grafana

Instalaremos Grafana mediante un script que ya he creado, lo descargaremos con el comando:

```bash
wget https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/scripts/grafana.sh && bash grafana.sh
```

El contenido del script es el siguiente:

```bash
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
```



# Instalación de Influxdb

Siguiendo la documentación oficial de Influxdb primero descargaremos el servidor y luego la interfaz de la linea de comandos para interactuar con influxdb, los instalaremos con el comando:

```bash
#Instalación de la BBDD
 wget https://download.influxdata.com/influxdb/releases/influxdb2_2.7.6-1_amd64.deb
dpkg -i influxdb2_2.7.6-1_amd64.deb
rm influxdb2_2.7.6-1_amd64.deb 

#Instalacion de la herramienta de CLI
wget https://download.influxdata.com/influxdb/releases/influxdb2-client-2.7.5-linux-amd64.tar.gz
tar xvzf influxdb2-client-2.7.5-linux-amd64.tar.gz
mv influx /usr/local/bin/
rm influxdb2-client-2.7.5-linux-amd64.tar.gz
```

# Instalación de Prometheus

Instalaremos Prometheus mediante un script que ya he creado, lo descargaremos con el comando:

```bash
wget https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/scripts/prometheus.sh && bash prometheus.sh
```

El contenido del script es el siguiente:

```bash
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
 	hash_node_prometheus_2_51_1=1f933ea7515e3a6e60374ee0bfdb62bc4701c7b12c1dbafe1865c327c6e0e7d2
  	hash_actual=$(sha256sum prometheus-2.51.1.linux-amd64.tar.gz | awk -F " " '{print $1}' )

	if [ $hash_node_prometheus_2_51_1 == $hash_actual ];then
    		tar -xf prometheus-2.51.1.linux-amd64.tar.gz 	
		read -p "Presiona intro para continuar"
  	else
		rm prometheus-2.51.1.linux-amd64.tar.gz
  		exit 1
   	fi
	
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
	" > /etc/prometheus/prometheus.yml

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
```
