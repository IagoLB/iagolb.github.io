---
title: Seguridad de los servicios
layout: default
parent: Seguridad
nav_order: 3
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

# Seguridad de los servicios

Utilizaremos la estructura de carpetas de `/etc/keys` para crear certificados auto-firmados para activar el protocolo HTTPS en todos nuestros servicios.

Empezaremos creando las carpetas de grafana e influxdb.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/242.png" />

Crearemos los certificados igual que en el apartado anterior

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/243.png" />

Limitaremos el acceso a esos certificados al usuario y grupo propios de cada aplicación.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/24.4png" />

## Grafana

Para habilitar el HTTPS en Grafana deberemos ir a su fichero `/etc/grafana/grafana.ini` y modificar las siguientes líneas.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/245.png" />

Modificando esas 3 líneas habilitaremos en Grafana el protocolo HTTPS y le indicaremos el certificado y el key necesarios para su verificación.

Si accedemos ahora a Grafana nos dará otro aviso por ser un certificado autofirmado, pero veremos que esta habilitado el protocolo HTTPS.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/26.png" />

## InfluxDB

Para habilitar el HTTPS en influxdb iremos a la ruta `/etc/influxdb` y editaremos el archivo config.toml añadiendo las rutas al certificado y la key.

```yaml
bolt-path = "/var/lib/influxdb/influxd.bolt"
engine-path = "/var/lib/influxdb/engine"
tls-cert= "/etc/keys/influxdb/influxdb.crt"
tls-key= "/etc/keys/influxdb/influxdb.key"
```

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/247.png" />

Reiniciaremos el servicio y al acceder a influxdb veremos que se activo correctamente el protocolo HTTPS.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/248.png" />

## Prometheus

Para finalmente securizar prometheus crearemos un archivo llamado webconfig.yml con el siguiente contenido:

```yaml
tls_server_config:
  cert_file: "/etc/keys/prometheus/prometheus.crt"
  key_file: "/etc/keys/prometheus/prometheus.key"
```

Editaremos el servicio de prometheus añadiendo la linea 
`--webconfig.file=/etc/prometheus/webconfig.yml`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/249.png" />

Recargaremos los servicios y reiniciaremos prometheus con el comando
`systemctl daemon-reload && systemctl restart prometheus && systemctl status prometheus`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/250.png" />

Al acceder a la interfaz web de prometheus veremos que ya esta activado el HTTPS

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/251.png" />

Con esto ya habremos securizado nuestros servicios críticos y podremos pasar a la protección general del servidor.