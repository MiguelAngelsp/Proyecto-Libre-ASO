#!/bin/bash
#Fecha y hora
FECHA=$(date +'%d/%m/%Y %H:%M:%S')

# Directorio destino
DIRECTORIO=/var/www/html/index.html

# Directorio monitorizar
ESTADOS=/var/www/html/servicios.html

# Actualizar paquetes
sudo apt update
#sudo apt upgrade

#Comprobar si apache2 esta instalado
dpkg - l | grep apache2
if [ $? == 1 ];
then
   echo 'SERVICIO apache2 SE ENCUENTRA INSTALADO'
else
   # Instalar servicio web, habilitarlo y ver su estado
   sudo apt install apache2
   sudo systemctl start apache2
   sudo systemctl enable apache2
fi

#Comprobar si mariadb esta instalado
dpkg - l | grep mariadb
if [ $? == 1 ];
then
   echo 'SERVICIO mariadb SE ENCUENTRA INSTALADO'
else
   # Instalar servicio web, habilitarlo y ver su estado
   sudo apt install mariadb
   sudo systemctl start mariadb
   sudo systemctl enable mariadb
fi

#Comprobar si el firewall esta instalado
dpkg - l | grep firewalld
if [ $? == 1 ];
then
   echo 'SERVICIO firewalld SE ENCUENTRA INSTALADO'
else
	# Instalacion del cortafuegos, iniciarlo y ver su estado
	sudo apt install firewalld
	sudo systemctl start firewalld
fi

# Agregar las reglas http y htpps al firewall
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
# Reiniciar el servicio
sudo firewall-cmd --reload	

# Definir los permisos para nuestro index
sudo chown -R $USER:$USER /var/www

#Contenido CSS para servicios.html
echo "
<!DOCTYPE html>
<html lang='es'>
    <head>
        <style type="text/css">
  	/* Estilo para el cuerpo de página */
body {
  padding: 25px;
}

/* Estilo para el encabezado h1 */
h1 {
  color: orange;
}

/* Estilo para el encabezado h2 */
h2 {
  color: brown;
  font-style:sans
}

/* Estilo para el parrafo fecha */
#date {
  font-style: italic;
  color: blue;
  font-weight: bold;
}

/* Estilo para texto servicios */
#servicios {
  color: blue;
  text-transform: capitalize;
}

/* Estilo para un servicio que se encuentra corriendo */
.encendido {
  color: green;
  font-weight: bold;
}

/* Estilo para un servicio que se encuentra detenido */
.detenido {
  color: red;
  font-weight: bold;
}

  </style>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <meta http-equiv='X-UA-Compatible' content='ie=edge'>
        <title>Instalacion de servicio WEB junto con monitorizacion de sus
            Servicios</title>
        <link rel='stylesheet' href='estilos.css'>
    </head>
    <body></body>
</html>
" > $ESTADOS

#COMPROBACIONES DE COMO SE ENCUENTRAN LOS SERVICIOS
# Declaración de la función
estado() {
    systemctl --quiet is-active $1
    if [ $? -eq 0 ]; then
        echo "
    	<p id='servicios'>Servicio $1 <span class='encendido'> ejecutándose</span> </p>
		" >> $ESTADOS
    else
        echo "
    	<p id='servicios'>Servicio $1 <span class='detenido'> detenido</span> </p>
		" >> $ESTADOS
    fi
}

#Construccion del index HTML junto con CSS interno
echo "
<!DOCTYPE html>
<html lang='es'>
    <head>
        <style type="text/css">
  	/* Estilo para el cuerpo de página */
body {
  padding: 25px;
}

/* Estilo para el encabezado h1 */
h1 {
  color: orange;
}

/* Estilo para el encabezado h2 */
h2 {
  color: brown;
  font-style:sans
}

/* Estilo para el parrafo fecha */
#date {
  font-style: italic;
  color: blue;
  font-weight: bold;
}

/* Estilo para texto servicios */
#servicios {
  color: blue;
  text-transform: capitalize;
}

/* Estilo para un servicio que se encuentra corriendo */
.encendido {
  color: green;
  font-weight: bold;
}

/* Estilo para un servicio que se encuentra detenido */
.detenido {
  color: red;
  font-weight: bold;
}

  </style>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <meta http-equiv='X-UA-Compatible' content='ie=edge'>
        <title>Instalacion de servicio WEB junto con monitorizacion de sus
            Servicios</title>
        <link rel='stylesheet' href='estilos.css'>
    </head>
    <body>
        <h1>Se instala el servico WEB a fecha: <p id='date'>$FECHA</p></h1>
        <a href="http://localhost/servicios.html" target="_blank">COMPROBEMOS
            LOS SERVICIOS</a>
    </body>
</html>
" > $DIRECTORIO

# Servicios a chequear
# El servidor web Apache
estado apache2
# El firewall 
estado firewalld
# El servidor de bases de datos
estado mariadb

#Abrir nuestro index.html
gio open http://localhost/index.html
