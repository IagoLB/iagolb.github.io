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

### Visión de las métricas

Una vez que hemos configurado en nuestro dominio los exporters, si nos dirigimos a la interfaz web de Prometheus en el puerto 9090 y vamos a la opción de `status > targets`, veremos que ha detectado los DCs.

![[146.png]]

Si pulsamos sobre alguno de los `endpoints` nos redirigirá a la página creada por los exporters y podremos ver las métricas.

![[147.png]]

Como sólo hemos configurado la recolección de métricas de los servidores no detecta, por lo que a continuación crearemos un servicio de descubrimiento para prometheus.

### Service discovery

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

Para crear ese archivo vamos a crear un script en Python que se ejecute mediante una tarea cron en caso de que más adelante se añadan nuevos equipos.