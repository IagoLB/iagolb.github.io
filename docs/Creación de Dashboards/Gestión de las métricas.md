---
title: Gestión de las métricas
layout: default
parent: Creación de Dashboards
nav_order: 2
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

# Visión de las métricas

Una vez que hemos configurado en nuestro dominio los exporters, si nos dirigimos a la interfaz web de Prometheus en el puerto 9090 y vamos a la opción de `status > targets`, veremos que ha detectado los DCs.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/146.png" />

Si pulsamos sobre alguno de los `endpoints` nos redirigirá a la página creada por los exporters y podremos ver las métricas.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/147.png" />

Como sólo hemos configurado la recolección de métricas de los servidores no detecta, por lo que a continuación crearemos un servicio de descubrimiento para prometheus.

# Service discovery

Para crear la configuración de service discovery en Prometheus tenemos que indicarle como vamos a añadirla en el fichero `prometheus.yml`, en mi caso he decidido usar un `file_sd_discovery`, que consiste en añadir direcciones IP a un archivo en formato `yaml` que serán scrapeadas por Prometheus, para ello añadiremos la siguiente configuración en el fichero `prometheus.yml`

``` bash
global:
  scrape_interval: 90s

scrape_configs:
  - job_name: 'Servers'
    scrape_interval: 60s
    scrape_timeout: 5s
    static_configs:
      - targets: ['172.19.0.10:9182']
        labels:
         hostname: 'DC-01'
         type: 'Server'

      - targets: ['172.19.0.11:9182']
        labels:
         hostname: 'DC-02'
         type: 'Server'

  - job_name: 'Clientes'
    file_sd_configs:
      - files:
        - clientes.yml
```

Para crear ese archivo vamos a crear un script en Python que se ejecute mediante una tarea cron en caso de que más adelante se añadan nuevos equipos, el script será el siguiente:

```python
#!/usr/bin/python3

import subprocess
import concurrent.futures

def ping(ip):
    command = f"ping -c 1 -W 1 -l 64 {ip}"
    result = subprocess.run(command, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return f"'{ip}:9182'" if result.returncode == 0 else None

def ping_with_notification(ip):
    print(f"Pingeando: {ip}")
    return ping(ip)

def main():
    ip_range = [f"172.19.0.{i}" for i in range(20, 250)]

    results = []
    with concurrent.futures.ThreadPoolExecutor() as executor:
        future_to_ip = {executor.submit(ping_with_notification, ip): ip for ip in ip_range}
        for future in concurrent.futures.as_completed(future_to_ip):
            ip = future_to_ip[future]
            if future.result() is not None:
                results.append(future.result())

    output = "- targets: [" + ", ".join(results) + "]\n"

    with open("clientes.yml", "w") as output_file:
        output_file.write(output)

    print("Ping completado. Las direcciones IP que respondieron se han guardado en clientes.yml.")

if __name__ == "__main__":
    main()
```

Por defecto prometheus escanea el archivo yml para añadir nuevos targets cada 300 segundos, por lo que crearemos un script para un servicio que se ejecute en bucle cada 300 segundos.

```bash
#!/bin/bash
while true;do

	/usr/bin/python3 /etc/prometheus/targets.py
	sleep 300
	
done
```

Y para ejecutarlo crearemos el servicio `targets.service`, con el siguiente contenido:

```bash
[Unit]
Description=Script para la actualización de targets

[Service]
ExecStart=/etc/prometheus/scripts/targets.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Una vez que comprobamos que el servicio funciona lo activamos para que se ejecute automáticamente con el inicio del sistema.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/148.png" />

Si ahora miramos en la interfaz web de Prometheus veremos ahora esta obteniendo métricas también de los clientes.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/149.png" />

Con todo esto ya estamos listos para empezar a crear nuestros Dashboards en Grafana.