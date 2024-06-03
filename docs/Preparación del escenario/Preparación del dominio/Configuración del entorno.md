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


#### Preparación
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

También deberemos añadir la ruta del binario de php a las variables de entorno.

![[118.png]]

Para habilitar el php en el servidor accedemos a la configuración de IIS  y en la configuración del servidor vamos a asignaciones de controlador.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/118.png" />

Agregamos una asignación de módulo y cumplimentamos los campos de la siguiente manera:

- Ruta de acceso de solicitudes: Las extensiones que se le asignaran al ejecutable.
- Módulo: El modulo encargado de cargar php
- Ejecutable: Ruta del binario que ejecutara el php
- Nombre: Un nombre descriptivo.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/119.png" />

Creamos una pequeña página en php llamada test.php con el siguiente contenido para probar que funciona.

```php
<?php 
	phpinfo();
 ?>
```

En caso de obtener el siguiente error:

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/121.png" />

Tendremos que descargar el `Microsoft Visual C++ Redistributable para Visual Studio 2022`, preferiblemente desde la página oficial de Microsoft.

Tras la instalación ya tendremos el Php funcional.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/122.png" />

Crearemos dos usuarios desde la herramienta de `Usuarios y equipos de Active directory`, los usuarios se crearán con `Click derecho > Nuevo > Usuario`, introduciremos su nombre y contraseña y serán creados.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/123.png" />

También crearemos un Alias DNS para facilitar el acceso a los usuarios, para ello vamos a la herramienta de DNS y a la zona de búsqueda directa de DamBeaver, seleccionamos la opción de crear `Alias nuevo (CNAME)...`, introducimos el nombre que será el alias y el nombre del dominio al que estará unido.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/124.png" />

Debería haberse añadido un registro CNAME apuntando a `DC-02`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/125.png" />

#### Creación

Ahora empezaremos la creación de la aplicación de registro horario, la aplicación constará de 3 fases:

- **Portal de inicio de sesión**.
	Página en la que los usuarios introducirán sus credenciales para su validación.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/126.png" />

- **Control de inputs y comprobación de credenciales**.
	Página donde se sanitizarán y validarán las credenciales introducidas por el usuario y será redirigido a la página de fichajes si las credenciales son validas, o será devuelto a la página de login en caso contrario.
	
	- Credenciales invalidas:
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/127.png" />
	- Credenciales válidas:
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/128.png" />


- **Página de fichajes**.
	Página donde se realizará el fichaje de inicio y de fin de jornada.
	- Antes de realizar fichaje:
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/129.png" />
	- Después de realizar fichaje:
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/130.png" />


#### Código

- **Portal de inicio de sesión**
	- html
	``` html
	<!DOCTYPE html>
	<html lang="en">
	<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Login</title>
	<link rel="stylesheet" href="style.css">  
	</head>
	<body>
	
	<?php
	  session_start();
	?>
	
	<h1>Login DamBeaver</h1>
	<form action="login.php" method="POST" class="login-form">
	<div class="imgcontainer">
	  <img src="Icono.png" width="200" height="200"  alt="Avatar" class="avatar">
	</div>
	<label for="usuario">Usuario:</label>
	<input type="text" name="usuario" id="usuario" required> <br>
	<label for="contraseña">Contraseña:</label>
	<input type="password" name="contraseña" id="contraseña" required> <br>
	<input type="submit" name="login" value="Iniciar Sesión">
	</form>
	</body>
	</html>
	```

	-  css
	```css
	h1 {
	position: absolute;
	top: 0; 
	left: 0;
	width: 100%;
	text-align: center; 
	   margin-bottom: 20px; 
	 }
	 
	 body {
	   font-family: sans-serif;
	   margin: 0;
	   padding: 20px;
	   display: flex;
	   justify-content: center;
	   align-items: center;
	   min-height: 100vh;
	   background-color: #f0f0f0;
	 }
	
	 
	 .login-form {
	   background-color: #fff;
	   padding: 20px;
	   border-radius: 5px;
	   box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
	   width: 300px;
	 }
	
	 
	 label {
	   display: block;
	   margin-bottom: 5px;
	   font-weight: bold;
	 }
	
	
	   input[type="text"],
	   input[type="password"] {    
	   width: 80%;
	   padding: 10px;
	   border: 1px solid #ccc;
	   border-radius: 3px;
	   margin-bottom: 15px;
	 }
	
	
	 input[type="submit"] {
	   background-color: #4CAF50;
	   color: white;
	   padding: 10px 20px;
	   border: none;
	   border-radius: 5px;
	   cursor: pointer;
	 }
	
	 
	 input[type="submit"]:hover {
	   background-color: #3e8e41;
	 }
	
	 .imgcontainer {
	   text-align: center;
	    margin: 24px 0 12px 0;
	 }
	```
- **Control de inputs y comprobación de credenciales**.
	- login.php
	```php
	<?php
	session_start();
	$_SESSION["usuario"]=$_POST["usuario"];
	
	$adServer = "172.19.0.11";
	
	# Sanetizar el input del usuario
	$userAd = filter_input(INPUT_POST, 'usuario', FILTER_SANITIZE_STRING);
	$contraseñaAd = filter_input(INPUT_POST, 'contraseña', FILTER_SANITIZE_STRING);
	
	if (empty($userAd) || empty($contraseñaAd)) {
	  echo "Debes rellenar todos los campos";
	  session_destroy();
	  header("refresh:2, url=login.html");
	  exit;
	}
	
	# Estructura para comprobar que el usuario existe en el dominio
	$ldapDn = "CN=" . $userAd . ",OU=Usuarios,DC=dambeaver,DC=com";
	
	# Conexión al dominio
	$ldap = ldap_connect($adServer);
	
	if ($ldap) {
	  $bind=@ldap_bind($ldap, $ldapDn, $contraseñaAd);
	  if ($bind) {
	    echo $_SESSION["usuario"] .  " Has iniciado sesión correctamente, redirigiendo a la página de fichajes";
	    header("refresh:5, url=fichaje.php");
	  } else {
	    $error = ldap_error($ldap);
	    echo "Credenciales invalidas, volviendo a la página de login";       
	    session_destroy();
	    header("refresh:20, url=login.html");
	  }
	  
	  ldap_close($ldap);
	} else {
	  echo "Error en la conexión";
	  session_destroy();
	  header("refresh:20, url=login.html");
	}

	```
- **Página de fichajes**
	- fichaje.php
	```php
	<?php
	session_start(); 
	
	# Conexión a la BBDD
	$servidor = "172.19.0.11";
	$usuario = "fichajes";
	$contrasena = "abc123.";
	$bd = "RegistroHorario";
	$idConex = mysqli_connect($servidor, $usuario, $contrasena, $bd);
	
	if (mysqli_connect_errno()) {
	  echo "Error en la conexión: " . mysqli_connect_error();
	  die();
	}
	
	if (!mysqli_select_db($idConex, $bd)) {
	  echo "Error en la base de datos: " . mysqli_error($idConex);
	  die();
	}
	
	# Comprobamos que existe "usuario" como variable de sesión
	if (isset($_SESSION["usuario"])) {
	
	  echo "Has iniciado sesion como: " . $_SESSION["usuario"];
	
	  #Creamos el formulario para el fichaje
	  echo "<form action='' method='post'>"; 
	  echo "<input type='hidden' name='fichar' value='1'>"; 
	  echo "<input type='submit' value='Fichar'>";
	  echo "</form>";
	
	  # Comprueba si el usuario ha pulsado en "fichar"
	  if (isset($_POST["fichar"])) {
	    $usuario = $_SESSION["usuario"];
	    $fecha = date("Y-m-d");
	    $hora = date("H:i:s");
	
	    # Comprobamos si el usuario ha fichado en la fecha actual
	    $sql = "SELECT * FROM fichajes WHERE usuario = '$usuario' AND fecha = '$fecha'";
	    $result = mysqli_query($idConex, $sql);
	
	    /*
	    Si devuelve alguna columna significa que ya ha fichado en el día
	    por lo tanto en vez de aparecer para fichar aparece un boton para 
	    finalizar la jornada
	    */
	    if ($result->num_rows > 0) {      
	      echo "<form action='' method='post'>"; // 
	      echo "<input type='hidden' name='usuario' value='$usuario'>";
	      echo "<input type='hidden' name='finalizar' value='1'>";
	      echo "<input type='submit' value='Finalizar jornada'>";
	      echo "</form>";
	    } else {
	      # Si el usuario no ha fichado en el día, guarda la fecha y hora en la tabla de fichajes
	      $sql = "INSERT INTO fichajes (usuario, fecha, hora) VALUES ('$usuario', '$fecha', '$hora')";
	      mysqli_query($idConex, $sql);
	
	      echo "Fichaje registrado correctamente";
	
	      # Recargamos la página para cuando se quiera finalizar la jornada
	      header("Refresh: 2; url=" . $_SERVER['PHP_SELF']);
	      exit();
	    }
	  }
	
	  // Finalizar jornada
	  if (isset($_POST["finalizar"])) {
	    $usuario = $_SESSION["usuario"];
	    $fecha = date("Y-m-d");
	    $hora = date("H:i:s");
	
	    $sql = "UPDATE fichajes SET horaSalida = '$hora' WHERE usuario = '$usuario' AND fecha = '$fecha'";
	    $result = mysqli_query($idConex, $sql);
	
	    if ($result) {
	      echo "Jornada finalizada correctamente";
	
	      # Destruir sesion al haber finalizado la jornada
	      session_destroy();
	      
	      header("Location: login.html"); 
	      exit();
	    } else {
	      echo "Error actualizando la salida: " . mysqli_error($idConex);
	    }
	  }
	} else {
	  # Si hubo algún error en el paso de variables
	  echo "Error en la sesión, volviendo a la página de login";
	  session_destroy();
	  header("refresh:2, url=login.html");
	}
	
	mysqli_close($idConex); 
	?>
	```

### Creación del servicio de exportación de métricas

#### Preparación de archivos

Para el servicio de exportación crearemos dos carpetas compartidas, una en cada DC del dominio con los archivos necesarios para la creación del servicio, de tal forma que siempre estén disponibles, la instalación se hará de forma automática mediante una GPO.

Empezaremos con la creación de las carpetas compartidas:

- Creamos la carpeta `Exporter` en la raíz de `C:\`  y la compartimos con permisos de lectura.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/131.png" />

- Dentro de la carpeta copiamos el binario de instalación que se puede descargar desde el [Repositorio de github](https://github.com/prometheus-community/windows_exporter) y crearemos también un archivo para su configuración, el cual será el siguiente:
```yml
collectors:

  enabled:  cpu,cpu_info,cs,logical_disk,memory,net,os,process,service,system,tcp,iis,dns,dhcp #indicamos los colectores que usará

log: 

  level: info # indicamos el nivel de log que queremos tener
```

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/132.png" />

- Crearemos un script para su instalación mediante GPO:

```powershell
try { 
  $servicio = (Get-Service -Name node_exporter -ErrorAction SilentlyContinue) -ne $null #comprueba si existe el servicio
} catch {  
  $servicio = $null
}

if (!(Test-Path -Path "c:\Exporter")) {  #comprueba si existe la ruta
  New-Item -ItemType Directory "c:\Exporter"
}

if (!$servicio) {  #sino existe el servicio lo crea

  try {
    Copy-Item "\\172.19.0.10\exporter\exporter.exe" "c:\Exporter\exporter.exe" -Force
    Copy-Item "\\172.19.0.10\exporter\config.yml" "c:\Exporter\config.yml" -Force
    } catch {        
    Copy-Item "\\172.19.0.11\exporter\exporter.exe" "c:\Exporter\exporter.exe" -Force
    Copy-Item "\\172.19.0.11\exporter\config.yml" "c:\Exporter\config.yml" -Force
    }
    
  New-Service -Name node_exporter -DisplayName "node_exporter" -BinaryPathName "c:\Exporter\exporter.exe --config.file=c:\Exporter\config.yml --log.file=log.txt" -StartupType Automatic
    
  Start-Service -Name node_exporter  -InformationAction SilentlyContinue 
}	
```

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/133.png" />

#### Creación de la GPO

Para la creación de la GPO para el despliegue automático en el dominio iremos al `Administrador del servidor > Herramientas > Administración de directivas de grupo`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/134.png" />

Pulsaremos click derecho sobre nuestro dominio y elegimos la opción de `Crear un GPO en este dominio y vincularlo aquí...`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/135.png" />

Le asignamos un nombre.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/136.png" />

Editamos la GPO para asignarle propiedades.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/137.png" />

Vamos a `Configuración del equipo > Directivas > Configuración de Windows > Scripts (inicio o apagado) > Inicio` y asignamos el script que hemos creado para que se ejecute al inicio de windows.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/138.png" />

Desactivaremos también el firewall de windows (actividad común en entornos empresariales) para no tener problemas con las lecturas de métricas, crearemos una GPO llamada `Desactivar firewall` y la configuraremos en la ruta `Configuración de equipo > Plantillas administrativas > Componentes de Windows > Red > Conexiones de red > Firewall de Windows Defender > Perfil de dominio > Firewall de Windows Defender: proteger todas las conexiones de red` y la desactivamos.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/139.png" />

Para hacer la comprobación, comprobamos si existe el servicio `node_exporter`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/140.png" />

Reiniciamos y ejecutamos otra vez el `cmdlet`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/141.png" />

Y si comprobamos el Firewall podemos ver que está desactivado.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/142.png" />

Tras realizar estas configuraciones vamos a introducir 2 equipos para los cuales ya hemos creado los usuarios para recolectar métricas más adelante.

Tras iniciar los equipos podemos ver que ya obtienen la configuración IP y DNS automáticamente gracias el servicio DHCP que hemos configurado, por lo cual lo único que tendremos que hacer es unirlos al dominio.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/143.png" />

Para añadirlo a dominio vamos a `Sistema > Cambiar el nombre de este equipo (Avanzado) > Cambiar` e introducimos el nombre del dominio y unas credenciales válidas.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/144.png" />

Si las credenciales fueron correctas nos saldrá un mensaje diciendo que nos hemos unido correctamente.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/145.png" />

Tras esto empezaremos a construir nuestros dashboard en grafana.