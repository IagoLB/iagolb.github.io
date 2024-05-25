---
title: Configuración del entorno
layout: default
parent: Preparación del dominio
grand_parent: Preparación del escenario
nav_order: 3
has_children: true
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

### Creación de una aplicación para el control horario

Vamos a crear una pequeña aplicación, para simular un entorno real de una Pyme, para el registro horario de los empleados usando una base de datos [MariaDB](https://mariadb.org/download/?t=mariadb&p=mariadb&r=11.3.2&os=windows&cpu=x86_64&pkg=msi&mirror=fe_up_pt) y [Php para IIS](https://windows.php.net/qa/), empezaremos instalando y configurando MariaDB.

Iniciamos la instalación y eliminamos las opciones de instalación de las librerías `C/C++`, así como las herramientas de terceros.
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/110.png" />

Configuramos la contraseña de root, y dejamos deshabilitado su inicio de forma remota y establecemos que la BBDD usará `UTF-8`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/111.png" />

En la siguiente pantalla dejaremos las opciones por defecto.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/112.png" />

Dejamos que finalice la instalación.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/113.png" />

Ya que el instalador no añade los binarios al PATH, los añadiremos manualmente `Sistema > Configuración avanzada del sistema > variables de entorno > path > editar > nuevo` y añadimos la ruta de los binarios.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/114.png" />

Accedemos al CLI de MariaDB y creamos una base de datos y una tabla para la aplicación.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/115.png" />

Creamos un usuario que será el que inserte y modifique los datos y le damos permisos en la tabla.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/116.png" />

Ahora instalaremos el php, para ello descargamos el binario NTS, ya que es el recomendado para IIS, descargaremos un zip que se descomprime en una ruta y se ejecuta desde ahí, en mi caso lo descomprimiré en C:\\PROGRAM DATA\\php.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/117.png" />

Ahora debemos abrir con un editor de texto el archivo `php.ini-production`, también deberemos renombrarlo a `php.ini` y descomentar las líneas:
```txt
extension_dir = "ext" # Esta línea indica la ruta del directorio donde se encuentran las extensiones de PHP en Windows
extension=ldap        # Esta línea habilita la extensión LDAP
extension=mysqli      # Esta línea habilita la extensión MySQLi
```

Para habilitar el php en el servidor accedemos a la configuración de IIS  y en la configuración del servidor vamos a asignaciones de controlador.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/118.png" />

Agregamos una asignación de módulo y cumplimentamos los campos de la siguiente manera:

- Ruta de acceso de solicitudes: Las extensiones que se le asignaran al ejecutable.
- Módulo: El modulo encargado de cargar php
- Ejecutable: Ruta del binario que ejecutara el php
- Nombre: Un nombre descriptivo.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/119.png" />