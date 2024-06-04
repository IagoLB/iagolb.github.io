---
title: Seguridad del servidor
layout: default
parent: Seguridad
nav_order: 5
has_children: false
has_toc: false
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

# Seguridad del servidor

Aunque podamos trabajar con la mayoría de los servicios, hemos visto que las configuraciones deben hacerse desde el servidor por consola, a día de hoy esto se hace mediante el protocolo `SSH` o `Secure Shell`, aunque una opción ideal es usar el sistema de claves asimétricas para la autentificación, es muy común en las empresas que aún se acceda por clave, así que protegeremos esta parte.

Para ello instalaremos el fail2ban y el iptables.

`apt install fail2ban iptables -y`

Crearemos el archivo `/etc/fail2ban/jail.local ` con el siguiente contenido:

``` bash
[sshd] #El servicio a proteger
enabled = true #Filtro activado o descativado
port = 22 #Puerto por el que escuchará, el ssh es el 22
filter = sshd #El nombre de la cadena de utilizada para filtrar las conexiones SSH entrantes
logpath = /var/log/auth.log #Donde se guardaran los logs
maxretry = 3 #Intentos antes de bloquear esa IP
findtime = 300 #Intervalo para contar los intentos, en segundos
bantime = 3600 #Duración del bloqueo, en segundos

```

Y modificaremos el fichero por defecto de configuración de `ssh` en la ruta `/etc/ssh/sshd_config` y comentaremos la ruta que permite conectarse directamente como root, al ser un objetivo común de los ataques.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/252.png" />

Tras esto reiniciaremos el servicio ssh y habilitaremos y activaremos el servicio de fail2ban.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/253.png" />

Tras esto si realizamos un ataque de fuerza bruta pasados los 3 intentos obtendremos el error `conexin refused`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/254.png" />

Y si miremos el estado de la `jail` obtendremos los datos, como el total de fallos, las IPs actualmente bloqueadas y el total de baneadas, así como una lista de las IPs bloqueadas.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/255.png" />

Con esto habremos protegido el servidor ante los ataques por ssh, aunque recomendaría fuertemente el uso de claves para la autentificación.