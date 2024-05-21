---
title: Configuración del entorno
layout: default
parent: Preparación del servidor de monitorización
grand_parent: Preparación del escenario
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
### Configuración de los paquetes

Ya hemos instalado todo lo necesario para desplegar el servidor de monitorización, ahora vamos empezar a configurar los servicios y a conectarlos entre si, empezando con 
Prometheus, seguiremos con Influxdb y finalizando con Grafana.

### Prometheus

Prometheus obtiene sus objetivos del fichero `Prometheus.yml`, ubicado en la ruta `/etc/prometheus`. Durante la instalación hemos creado una pequeña configuración como esqueleto, la comentaré ahora:

``` yaml
global: # Esta etiqueta indica que los valores de esta parte se aplicaran a toda la estructura siempre y cuando no haya otra etiqueta que la contradiga
  scrape_interval: 15s #El tiempo entre intentos de prometheus para obtener metricas
scrape_configs: 
  - job_name: 'prometheus' #Nombre que se le asignara al proceso de los siguientes targets
  scrape_interval: 5s #El tiempo entre intentos de prometheus para obtener metricas
  scrape_timeout: 4s #El tiempo máximo que esperará prometheus antes de considerar que una consulta ha fallado
  static_configs: #Define una lista de objetivos estáticos
    - targets: ['localhost:9090'] #El objetivo del que obtendrá métricas será el localhost, y buscará las metricas en el puerto 9090
``` 

Es muy importante la identación del archivo, ya que estamos ante un fichero en formato `yaml`, y una mala identación nos dará fallos en la configuración.

Para las primeras pruebas crearemos el siguiente fichero:

``` yaml
global:
  scrape_interval: 60s

scrape_configs:
  - job_name: 'Servers'
  scrape_interval: 60s
  scrape_timeout: 5s
  static_configs:
    - targets: ['172.19.0.10:9182'] #El exporter que usaremos expone las métricas en el puerto 9182
      labels: #Usamos esta opción para indicar que vamos a crear etiquetas para asociar una IP a un nombre concreto
       hostname: 'DC-01' #Nombre asociado a la IP
       type: 'server' #Esta etiqueta asigna el tipo "server" al servidor de destino.

    - targets: ['172.19.0.11:9182']
      labels:
       hostname: 'DC-02'
       type: 'server'
```

Es importante para confirmar que no de fallos usar la herramienta `promtool`, la cual viene con Prometheus para checkear diversas configuraciones de Prometheus.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/01.png" />

Con esta configuración Prometheus recogerá automaticamente las métricas que se expongan en esas dos direcciones IP en los puertos 9182, hay que recordar siempre recargar el servicio para actualice la configuración y comprobar que el servicio se ejecuto correctamente.
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/02.png" />


### Influxdb

Influxdb puede configurarse tanto por linea de comandos con `influx` como por vía web en el puerto 8086, la primera configuración será más cómoda por vía web, es por donde lo haremos en este tutorial.

1. Iniciamos el servicio influxdb, ya que en la instalación no lo activamos.
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/03.png" />

2. Al acceder desde el navegador en otra máquina nos saldrá esta interfaz la primera vez para su configuración. 
 <img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/04.png" />
 3. Nos pedirá la creación de un usuario y su contraseña, así como la creación de una  `organization` y un `bucket`
	 1. Un **bucket** es: Un bucket es una unidad de almacenamiento en InfluxDB que almacena datos de series temporales. Cada bucket tiene un nombre único, una política de retención
	 2. Una **organization** es: Una organización es un contenedor lógico en InfluxDB que agrupa buckets y usuarios.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/05.png" />

4. Finalmente habremos acabo la configurando, nos saldrá un token, el cual será necesario luego para realizar configuraciones.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/06.png" />

5. Una vez ya dentro de Influxdb accedemos a la parte de los scrapers para configurar la recogida de métricas de Prometheus pulsando en `Create scraper`. 

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/07.png" />

6. Deberemos asignarle un nombre, y elegir el bucket donde se guardarán las métricas, también debemos especificar la IP y puerto de donde recogerá las métricas, por defecto Prometheus expone sus métricas en el puerto 9090
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/08.png" />

7. Un ejemplo de como serían las métricas y el lenguaje `Flux`, lenguaje usado por Influxdb
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/09.png" />

El código es el siguiente:

``` 
from(bucket: "Dambeaver") // Nombre del bucket del que se leen los datos
|> range(start: v.timeRangeStart, stop: v.timeRangeStop) // Dos variables que representan el tiempo
|> filter(fn: (r) => r["_measurement"] == "prometheus_http_response_size_bytes") // el campo que estamos midiendo, en este caso el tamaño de las respuestas http de prometheus
|> filter(fn: (r) => r["_field"] == "count") // Nos dice que esta contando el número de datos, en este caso cuenta el número de solicitudes
|> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false) //define el tamaño de la ventana "v.windowPeriod"
//"fn:mean" La función para aplicar dentro de cada ventana. En este caso, calcula la mean (media)
//"createEmpty: false" asegura que la consulta no devuelva resultados vacíos para ventanas sin puntos de datos
|> yield(name: "mean") // el nombre otorgado de la serie de datos
```


### Grafana

Grafana se configura en su mayoría por vía web, aunque podemos modificar su configuración en el fichero `/etc/grafana/grafana.ini`, hay configuraciones interesantes que veremos más adelante, en el fichero podemos modificar opciones como el protocolo que usará por defecto, si usará certificados para mejorar su seguridad, la IP en la que se expondrá el servicio y/o su puerto, así como las credenciales por defecto que usaremos la primera vez, así como la configuración de smtp para enviar alertar, lo cual veremos más adelante.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/10.png" />

Por ahora dejaremos la configuración por defecto.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/11.png" />

Inmediatamente para una mejor seguridad nos exigirá cambiar la contraseña por una más compleja.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/12.png" />

Finalmente está es la interfaz web de Grafana.

![[13.png]]

Lo primero que deberemos hacer será añadir una fuente de datos, es lo haremos con `Open Menu > Connections > Add new conection`

![[14.png]]

Veremos una gran cantidad de posibles fuentes de datos, aunque en nuestro caso elegiremos 