---
title: Seguridad de las métricas
layout: default
parent: Seguridad
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

# Seguridad de las métricas

Ya tenemos nuestro dashboard finalizado y es: `más bonito que un tractor recién pintao`, pero cualquiera que haga un escaneo de red verá que hay un servicio expuesto, y obtener las métricas es tan fácil como ejecutar un `curl` contra la dirección IP.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/231.png" />

Debido a lo expuestos que estamos necesitamos proteger nuestros datos, para ello vamos a securizar el servicio con certificados auto-firmados, y para los servidores añadiremos una capa extra de protección añadiendo una autentificación por usuario y contraseña.

## Autentificación

Empezaremos por la autentificación para los servidores instalando `apache2-utils` para la generación de las claves.

Usaremos el comando `htpasswd -nBC 12 admin` para generar el hash de la contraseña.

- Con `-n` hacemos que nos imprima el hash por pantalla en lugar de almacenarlo
- Con `B` indicamos que el hash usará el algoritmo `bcrypt`.
- Con `C 12` indicamos el coste del algoritmo, `C 12` es un coste bastante seguro y comúnmente utilizado.
- `admin` será el usuario para el que crearemos el hash, esta parte sería posible dejarla en blanco, ya que no es necesario especificarlo aquí.

Con esto obtendremos el hash, el cual deberemos de guardar para la autentificación.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/232.png" />

Con estos datos iremos a la configuración de prometheus y añadiremos en el job correspondiente el tag `basic_auth:`, en la configuración podemos poner los datos en texto plano o a través de un fichero, en mi caso lo pondré en texto plano, ya que restringiremos próximamente los permisos de acceso.

```yaml
global:
  scrape_interval: 90s

scrape_configs:
  - job_name: 'Server 1'
    basic_auth:
      username: 'admin'
      password: 'abc123.'
    scrape_interval: 15s
    scrape_timeout: 5s
    static_configs:
      - targets: ['172.19.0.10:9182']
        labels:
         hostname: 'DC-01'

  - job_name: 'Server 2'
    scrape_interval: 15s
    scrape_timeout: 5s
    static_configs:
      - targets: ['172.19.0.11:9182']
        labels:
         hostname: 'DC-02'

  - job_name: 'Clientes'
    scrape_interval: 15s

    file_sd_configs:
      - files:
        - clientes.yml
```

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/233.png" />

Hay que recordar reiniciar el servicio para que se aplique la configuración y comprobamos que se aplico correctamente la configuración y que se inició sin errores.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/234.png" />

Con esto finalizaremos la configuración en el servidor de prometheus y tocará configurar el dominio.

Para ello crearemos un archivo llamado `webconfig.yml` con el siguiente contenido:

```yaml
basic_auth_users:
  admin: $2y$12$6Y6SyZoF9bj/pqox2feIzuQS5vJurdA.HCMKJ62C8By/jyF47JY6q 
```

Y modificaremos el comando de creación del servicio para añadir la etiqueta `--web.config.file=`

Quedando la creación del servicio así:

`New-Service -Name node_exporter -DisplayName "node_exporter" -BinaryPathName "c:\Exporter\exporter.exe --config.file=c:\Exporter\config.yml --log.file=c:\Exporter\log.txt --collector.textfile.directories=C:\Exporter\test\ --web.config.file=C:\Exporter\webconfig.yml" -StartupType Automatic
`
Tras esto si volvemos a intentar hacer `curl` para obtener las métricas obtendremos el error de`Unauthorized`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/235.png" />

Pero si hacemos `curl` autentificándonos si que obtendremos las métricas.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/236.png" />

## HTTPS

Para el certificado usaremos el comando `openssl`, que ya viene instalado por defecto en `debian 12` para crear los certificados.

Crearemos una estructura de carpetas con el comando `mkdir -p`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/237.png" />

Para crear los ficheros para el certificado usaremos:

- Key: `openssl genpkey -algorithm RSA -out prometheus.key`
- Certificado: `openssl req -new -key prometheus.key -out prometheus.csr`
- Certificado auto-firmado: `openssl x509 -req -days 365 -in prometheus.csr -signkey prometheus.key -out prometheus.crt`

Cumplimentaremos los datos que nos haya pedido y obtendremos los ficheros cifrar los datos.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/238.png" />

En el fichero `prometheus.yml` necesitamos añadir la ruta a los ficheros 

```yaml
global:
  scrape_interval: 90s

scrape_configs:
  - job_name: 'Server 1'
    scheme: https
    tls_config:
      ca_file: '/etc/keys/prometheus/prometheus.crt'
      insecure_skip_verify: true

    basic_auth:
      username: 'admin'
      password: 'abc123.'
    scrape_interval: 15s
    scrape_timeout: 5s
    static_configs:
      - targets: ['172.19.0.10:9182']
        labels:
         hostname: 'DC-01'

  - job_name: 'Server 2'
    scheme: https
    tls_config:
      ca_file: '/etc/keys/prometheus/prometheus.crt'
      insecure_skip_verify: true

    scrape_interval: 15s
    scrape_timeout: 5s
    static_configs:
      - targets: ['172.19.0.11:9182']
        labels:
         hostname: 'DC-02'

  - job_name: 'Clientes'
    scheme: https
    tls_config:
      ca_file: '/etc/keys/prometheus/prometheus.crt'
      insecure_skip_verify: true

    scrape_interval: 15s

    file_sd_configs:
      - files:
        - clientes.yml
```

Y en los clientes necesitamos el `.crt` y el `.key`, configuraremos el archivo `webconfig.yml` de la siguiente manera:

```yml
tls_server_config:
  cert_file: prometheus.crt
  key_file: prometheus.key
basic_auth_users:
  admin: $2y$12$H9AlhegJzAx9oONaPZM9v.FqrV1rwR6MWASc0pGIY9SFdZROlLGee
```

No modificaremos el script del servicio, ya que seguimos usando el mismo archivo web.

Ahora si desde el servidor accedemos a la interfaz de prometheus veremos que el target tiene activado el https:

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/239.png" />

Si accedemos a él nos dará un aviso ya que no se puede verificar la autenticidad del certificado al ser auto-firmado.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/240.png" />

Y veremos que en la dirección de las métricas nos sale el candado del protocolo HTTPS.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/241.png" />

Con este hemos securizado las métricas para que estén cifradas, y las métricas del servidor que, a mayores, requieran una autentificación.