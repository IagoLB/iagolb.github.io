---
title: Instalación de paquetes
layout: default
parent: Preparación del servidor de monitorización
grand_parent: Preparación del escenario
nav_order: 1
has_children: false
has_toc: false
---

### Preparando la base

Partiendo de un SO recién instalado lo primero que haremos será actualizar los repositorios y los paquetes que tengamos con el comando:

```bash
apt update && apt upgrade
```

### Instalación de paquetes

Con el SO ya actualizado instalaremos los paquetes necesarios para realizar las instalaciones con el comando:

```bash
apt install wget apt-transport-https software-properties-common openssh-server apache2-utils sudo
```

La función de los paquetes instalados será la siguiente:
- - **wget:** Descargar archivos de Internet desde la línea de comandos.
- **apt-transport-https:** Permite que apt use HTTPS para descargar paquetes de repositorios.
- **software-properties-common:** Proporciona herramientas para administrar repositorios de software.
- **sudo**: Permite ejecutar comandos con privilegios elevados, mejorando la seguridad y la gestión del sistema.
- **openssh-server:** Permite que el servidor reciba conexiones de otros sistemas mediante SSH, este paquete será utilizado para la administración del servidor.
- **apache2-utils:** Herramientas de línea de comandos para administrar Apache 2, este paquete será utilizado para la creación de contraseñas de autentificación más adelante.

### Creación de usuarios

Debemos asignar un usuario para ejecutar los servicios de Grafana, de Prometheus y de Influxdb, por seguridad crearemos usuarios con el shell `/bin/false` para que no se pueda iniciar sesión con esos usuarios. Grafana e Influxdb ya lo crean automáticamente en la instalación, sólo será necesario crear el usuario de Prometheus, el comando será el siguiente:

```bash
adduser --no-create-home --shell /bin/false prometheus
```

### Instalación de Grafana

Instalaremos Grafana mediante un script que ya he creado, lo descargaremos con el comando:

```bash
wget https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/scripts/grafana.sh && bash grafana.sh
```

El contenido del script es:

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

