#!/bin/bash
# Comando "instalar"

#*******************************************Variables generales********************************************
msgError="Proceso de instalacion cancelado"
instalar=0
parametro=0
respuesta=""
dirValidado=""

#Variables de configuracion
PERLV=""
BINDIR="bin"
MAEDIR="mae"
ARRIDIR="arribos"
RECHDIR="rechazados"
REPODIR="reportes"
LOGDIR="log"
DATASIZE=100
LOGEXT=".log"
LOGSIZE=400

#****Directorios de la instalacion****
GRUPO=$PWD
DIRPPAL="$GRUPO"
CONFDIR="$DIRPPAL/confdir" #directorio de configuraciones
dirInst="$DIRPPAL/inst" #directorio donde se encuentran archivos de la instalacion

#****Archivos y comandos de la instalacion****
declare -a COMANDOS
declare -a ARCHIVOS
declare -a ARCH_OBL

COMANDOS=("LoguearU.sh" "MoverU.sh" "DetectarU.sh" "GrabarParqueU.sh" "IniciarU.sh" "MirarU.sh" "StopD.sh" "ListarU.pl" "StartD.sh")
ARCHIVOS=("prod.mae" "sucu.mae" "cli.mae")
ARCH_OBL=(${COMANDOS[*]} ${ARCHIVOS[*]})

arch_log_i="instalarU.log"
archConf="instalarU.conf"

#****Comandos****
log="./inst/LoguearU.sh instalarU" #permite llamar con "log mensaje"
chmod +x ./inst/LoguearU.sh

#***********************************************FIN - Variables Generales*************************************

#***********************************************Funciones Utilizadas******************************************

function pregunta 
{
	local preg="$1"
	local respValida=""
	
	echo ""
	while [ -z $respValida ]	#mientras no responda si o no
	do 
		read -p "$preg (SI / NO): " resp #leo la respuesta y la guardo en $resp
		respValida=$(echo $resp | grep -i '^[S][I]$\|^[N][O]$') #valido que la respuesta sea si o no
	done

	#transformo la respuesta a minuscula
	resp=$(echo $respValida | sed 's/^[Ss][Ii]$/si/')
	
	#transformo la respuesta en un numero
	if [ $resp = "si" ] 
	then
		respuesta=1
	else
		respuesta=0
	fi
}

function preguntarDirectorio {
	local resp=""
	while [ -z $resp ]
	do
		read -p "Ingrese nueva ubicacion: $DIRPPAL/" dirPasado
		resp=$(echo $dirPasado | grep "^[A-Za-z0-9%@_=:/\.]\{1,\}$")
		if [ -z $resp ]
		then 
			echo ""
			echo "El nombre de directorio $dirPasado es invalido"
			echo "Los unicos caracteres validos son alfanumericos y % @ _ = : / ."
		fi
	done
	dirValidado=$resp
}

function validarParametro 
{
	parametro=$(echo "$1" | grep '^DetectarU.sh$\|^IniciarU.sh$\|^StopD.sh$\|^StartD.sh$\|GrabarParqueU.sh$\|^ListarU.pl$')
	if [ -z $parametro ]; then
		echo "Debe escribir correctamente el nombre de los comandos, asegurese de leer el archivo README.txt"
		$log E "Debe escribir correctamente el nombre de los comandos, asegurese de leer el archivo README.txt"
		echo "Los parametros se escriben como: *IniciarU.sh *DetectarU.sh *GrabarParqueU.sh *StartD.sh *StopD.sh"
		$log E "Los parametros se escriben como: *IniciarU.sh *DetectarU.sh *GrabarParqueU.sh *StartD.sh *StopD.sh"
		exit 3
	fi
}

function leerVariablesDeConfiguracion
{
	GRUPO=`grep "GRUPO" "$1" | cut -d"=" -f 2`
	ARRIDIR=`grep "ARRIDIR" "$1" | cut -d"=" -f 2`
	RECHDIR=`grep "RECHDIR" "$1" | cut -d"=" -f 2`
	BINDIR=`grep "BINDIR" "$1" | cut -d"=" -f 2`
	MAEDIR=`grep "MAEDIR" "$1" | cut -d"=" -f 2`
	REPODIR=`grep "REPODIR" "$1" | cut -d"=" -f 2`
	LOGDIR=`grep "LOGDIR" "$1" | cut -d"=" -f 2`
	LOGEXT=`grep "LOGEXT" "$1" | cut -d"=" -f 2`
	LOGSIZE=`grep "LOGSIZE" "$1" | cut -d"=" -f 2`
	DATASIZE=`grep "DATASIZE" "$1" | cut -d"=" -f 2`
	DIRPPAL="$GRUPO"
	CONFDIR="$DIRPPAL/confdir"
	dirInst="$DIRPPAL/inst" 
}
 
function validarPerl {
	
	#***Chequeo la instalacion de perl***
	echo "Verificando versión de Perl instalada..."
    PERLV=$(perl -v | grep 'v[5-9]\.[0-9]\{1,\}\.[0-9]*' -o) #obtengo la version de perl

	#si perl no esta instalado o su version es menor a 5 termina
	if [ -z "$PERLV" ] 
	then
		msgErrorPerl="Para instalar el TP es necesario contar con Perl 5 o superior instalado. Efectue la instalacion e intentelo nuevamente."
		echo -e $msgErrorPerl
		$log E "$msgErrorPerl"
		$log E "Proceso de instalacion cancelado"
		exit 4
	else
		echo "Perl Version:$PERLV"
		$log I "Perl Version:$PERLV"
	fi
}

function MostrarDatosInstalacion
{
	#***Limpio la pantalla para mostrar configuracion final***
		clear
		
		$log I "Directorio de Trabajo: $GRUPO"
		echo "Directorio de Trabajo: $GRUPO"
		$log I "Libreria del sistema: $CONFDIR"
		echo "Libreria del sistema: $CONFDIR"		
		$log I "Directorio de instalacion de los ejecutables: $BINDIR"
		echo "Directorio de instalacion de los ejecutables: $BINDIR"
		$log I "Directorio de instalacion de los archivos maestros: $MAEDIR"
		echo "Directorio de instalacion de los archivos maestros: $MAEDIR"
		$log I "Directorio de arribo de archivos externos: $ARRIDIR"
		echo "Directorio de arribo de archivos externos: $ARRIDIR"
		$log I "Espacio minimo libre para el arribo de archivos externos: $DATASIZE Mb"
		echo "Espacio minimo libre para el arribo de archivos externos: $DATASIZE Mb"
		$log I "Directorio de grabacion de los archivos externos rechazados: $RECHDIR"
		echo "Directorio de grabacion de los archivos externos rechazados: $RECHDIR"
		$log I "Directorio de grabacion de los logs de auditoria: $LOGDIR"
		echo "Directorio de grabacion de los logs de auditoria: $LOGDIR"
		$log I "Extension para los archivos de log: $LOGEXT" 
		echo "Extension para los archivos de log: $LOGEXT"
		$log I "Tamaño maximo para los archivos de log: $LOGSIZE Kb"
		echo "Tamaño maximo para los archivos de log: $LOGSIZE Kb"
		$log I "Directorio de grabacion de los reportes de salida: $REPODIR"
		echo "Directorio de grabacion de los reportes de salida: $REPODIR"
	
}

function confirmarInicioInstalacion
{
	#***Confirmar inicio de instalacion***
	
	$log I "Iniciando Instalacion. Esta Ud. seguro?"
	pregunta "Iniciando Instalacion. Esta Ud. seguro?"
	if [ $respuesta -eq 1 ] 
	then # continuar instalacion
		instalar=1
	else
		instalar=0
	fi	 
}

function cargarParametrosInstalacion
{

	#grabo mensajes en el archivo de Log
	archivos=""
	$log I "Directorio de Trabajo para la instalacion: $GRUPO"
	echo "Directorio de Trabajo para la instalacion: $GRUPO"
	archivos=$(ls -l -Q "$GRUPO"| grep '"$' | sed -e"s/\"\{1,\}/;/g" | cut -f2 -d';')
	archivos=$(echo $archivos)	
	$log I "Lista de archivos y subdirectorios: $archivos"
	echo "Lista de archivos y subdirectorios: $archivos"

	$log I "Libreria del sistema: $CONFDIR"
	echo "Libreria del sistema: $CONFDIR"
	archivos=$(ls -l -Q "$CONFDIR"| grep '"$' | sed -e"s/\"\{1,\}/;/g" | cut -f2 -d';')	
	archivos=$(echo $archivos)	
	$log I "Lista de archivos y subdirectorios: $archivos"
	echo "Lista de archivos y subdirectorios: $archivos"

	$log I "Estado de la instalacion: PENDIENTE"
	echo "Estado de la instalacion: PENDIENTE"
	$log I "Para completar la instalacion ud. debera:"
	echo "Para completar la instalacion ud. debera:"

	$log I "Definir el directorio de instalacion de los ejecutables"
	echo "Definir el directorio de instalacion de los ejecutables"
	$log I "Definir el directorio de instalacion de los archivos maestros"
	echo "Definir el directorio de instalacion de los archivos maestros"
	$log I "Definir el directorio de arribo de archivos externos"
	echo "Definir el directorio de arribo de archivos externos"
	$log I "Definir el espacio minimo libre para el arribo de archivos externos"
	echo "Definir el espacio minimo libre para el arribo de archivos externos"
	$log I "Definir el directorio de grabacion de los archivos externos rechazados"
	echo "Definir el directorio de grabacion de los archivos externos rechazados"
	$log I "Definir el directorio de grabacion de los logs de auditoria"
	echo "Definir el directorio de grabacion de los logs de auditoria"
	$log I "Definir la extension y tamaño maximo para los archivos de log"
	echo "Definir la extension y tamaño maximo para los archivos de log"
	$log I "Definir el directorio de grabacion de los reportes de salida"
	echo "Definir el directorio de grabacion de los reportes de salida"

	#***COMIENZO DE CONFIGURACION DE INSTALACION***
	
	instalado=0
	while [ $instalado -eq 0 ] 
	do
		#***Definir directorio de instalacion de ejecutables***
		
		echo ""
		$log I "Defina el directorio de instalacion de los ejecutables ($DIRPPAL/$BINDIR):"
		echo "Defina el directorio de instalacion de los ejecutables ($DIRPPAL/$BINDIR):"
		echo "Nombre del directorio actual de instalacion: ($DIRPPAL/$BINDIR)"
		pregunta "Desea modificarlo?"
		if [ $respuesta -eq 1 ] 
		then # permitir modificacion
			preguntarDirectorio
			BINDIR=$dirValidado
		fi	
		$log I "Directorio de ejecutables: $DIRPPAL/$BINDIR"
		echo "Directorio de ejecutables:($DIRPPAL/$BINDIR)"


		#***Definir directorio de instalacion de los archivos maestros***
		
		$log I "Defina el directorio de instalacion de los archivos maestros ($DIRPPAL/$MAEDIR):"
		echo "Defina el directorio de instalacion de los archivos maestros ($DIRPPAL/$MAEDIR):"
		echo "Nombre del directorio actual de instalacion: ($DIRPPAL/$MAEDIR)"
		pregunta "Desea modificarlo?"
		if [ $respuesta -eq 1 ] 
		then # permitir modificacion
			preguntarDirectorio
			MAEDIR=$dirValidado
		fi
		$log I "Directorio de archivos maestros: $DIRPPAL/$MAEDIR"
		echo "Directorio de archivos maestros:($DIRPPAL/$MAEDIR)"


		#***Definir directorio de arribo de archivos externos***
		$log I "Defina el directorio de arribo de archivos externos ($DIRPPAL/$ARRIDIR):"
		echo "Defina el directorio de arribo de archivos externos ($DIRPPAL/$ARRIDIR):"
		echo "Nombre del directorio actual de instalacion: $DIRPPAL/$ARRIDIR"
		pregunta "Desea modificarlo?"
		if [ $respuesta -eq 1 ] 
		then # permitir modificacion
			preguntarDirectorio
			ARRIDIR=$dirValidado
		fi	
		$log I "Directorio de arribo de archivos externos: $DIRPPAL/$ARRIDIR"
		echo "Directorio de arribo de archivos externos: $DIRPPAL/$ARRIDIR"


		#***Calculo espacio libre en ARRIDIR***
		MAXSIZE=0
		#obtengo el espacio libre en el directorio(df -B). corto la unica linea que me devuelve,
		#reemplazo los espacios en blanco por '' (sed) y hago un cut del cuarto campo (cut)
		MAXSIZE=$(df -B1048576 "$DIRPPAL" | tail -n1 | sed -e"s/\s\{1,\}/;/g" | cut -f4 -d';')


		#***Definir espacio minimo libre para arribo de archivos externos***	
		fin=0
		$log I "Defina el espacio minimo libre para el arribo de archivos externos en Mbytes ($DATASIZE):"
		while [ $fin -eq 0 ]
		do		
			echo "Defina el espacio minimo libre para el arribo de archivos externos en Mbytes ($DATASIZE):"
			echo "Espacio minimo actual: $DATASIZE"			
			pregunta "Desea modificarlo?"
			if [ $respuesta -eq 1 ] 
			then # permitir modificacion
				read -p "Ingrese nuevo valor: " resp
				#valido que sea un numero
				respValida=$(echo $resp | grep "^[0-9]*$")			
				if [ $respValida ]
				then
					if [ $DATASIZE -gt $MAXSIZE ]
					then
						echo "Insuficiente espacio en disco."
						$log E "Insuficiente espacio en disco."
						echo "Espacio disponible: $MAXSIZE Mb."
						$log E "Espacio disponible: $MAXSIZE Mb."
						echo "Espacio requerido: $DATASIZE Mb."
						$log E "Espacio requerido: $DATASIZE Mb."
						echo "Cancele la instalacion e intentelo mas tarde o vuelva a intentarlo con otro valor."
						$log E "Cancele la instalacion e intentelo mas tarde o vuelva a intentarlo con otro valor."
					else
						DATASIZE=$respValida
						fin=1
					fi
				else
					echo "Por favor ingrese un numero entero"
				fi
			else
				fin=1
			fi
		done
		$log I "Espacio minimo libre para el arribo de archivos externos en Mbytes: ($DATASIZE)"
		echo "Espacio minimo libre para el arribo de archivos externos en Mbytes: ($DATASIZE)"


		#***Definir directorio de grabacion de los archivos rechazados***
		$log I "Defina el directorio de grabacion de los archivos externos rechazados ($DIRPPAL/$RECHDIR):"
		echo "Defina el directorio de grabacion de los archivos externos rechazados ($DIRPPAL/$RECHDIR):"
		echo "Nombre del directorio actual de grabacion de los archivos externos rechazados: $DIRPPAL/$RECHDIR"
		pregunta "Desea modificarlo?"
		if [ $respuesta -eq 1 ] 
		then # permitir modificacion
			preguntarDirectorio
			RECHDIR=$dirValidado
		fi	
		$log I "Directorio de grabacion de los archivos externos rechazados: $DIRPPAL/$RECHDIR"
		echo "Directorio de grabacion de los archivos externos rechazados: $DIRPPAL/$RECHDIR"
	

		#***Definir directorio de grabacion de los logs de auditoria***
		$log I "Defina el directorio de grabacion de los logs de auditoria ($DIRPPAL/$LOGDIR):"
		echo "Defina el directorio de grabacion de los logs de auditoria ($DIRPPAL/$LOGDIR):"
		echo "Nombre del directorio actual de grabacion de los logs de auditoria: $DIRPPAL/$LOGDIR"
		pregunta "Desea modificarlo?"
		if [ $respuesta -eq 1 ] 
		then # permitir modificacion
			preguntarDirectorio
			LOGDIR=$dirValidado
		fi
		$log I "Directorio de grabacion de los logs de auditoria: $DIRPPAL/$LOGDIR"
		echo "Directorio de grabacion de los logs de auditoria: $DIRPPAL/$LOGDIR"


		#***Definir la extension para archivos de log***
		fin=0
		$log I "Defina la extension para los archivos de log ($LOGEXT):"
		while [ $fin -eq 0 ]
		do		
			echo "Defina la extension para los archivos de log ($LOGEXT):"
			echo "Nombre actual de extension para los archivos de log: $LOGEXT"
			pregunta "Desea modificarlo?"
			if [ $respuesta -eq 1 ] 
			then # permitir modificacion
				read -p "Ingrese nueva extension: " resp
				#valido que sea un numero
				respValida=$(echo $resp | grep "^\.\([a-zA-Z0-9]\)\{1,\}$")			
				if [ $respValida ]
				then
					LOGEXT=$respValida
					fin=1				
				else
					echo "Por favor ingrese un . seguido del nombre de extension que desea"
				fi
			else
				fin=1
			fi
		done
		$log I "Extension para los archivos de log: $LOGEXT"
		echo "Extension para los archivos de log: $LOGEXT"


		#***Definir tamaño maximo para los archivos de log***	
		fin=0
		$log I "Defina el tamaño maximo para los archivos $LOGEXT en Kbytes ($LOGSIZE):"
		while [ $fin -eq 0 ]
		do		
			echo "Defina el tamaño maximo para los archivos $LOGEXT en Kbytes ($LOGSIZE):"
			echo "El tamaño maximo actual para los archivos de log es: $LOGSIZE Kbytes"			
			pregunta "Desea modificarlo?"
			if [ $respuesta -eq 1 ] 
			then # permitir modificacion
				read -p "Ingrese nuevo valor: " resp
				#valido que sea un numero
				respValida=$(echo $resp | grep "^[0-9]*$")			
				if [ $respValida ]
				then
					LOGSIZE=$respValida
					fin=1
				else
					echo "Por favor ingrese un numero entero"
				fi
			else
				fin=1
			fi
		done
		$log I "Tamaño maximo para los archivos de log en Kbytes: ($LOGSIZE)"
		echo "Tamaño maximo para los archivos de log en Kbytes: ($LOGSIZE)"


		#***Definir directorio de grabacion de los reportes de salida***
		$log I "Defina el directorio de grabacion de los reportes de salida ($DIRPPAL/$REPODIR):"
		echo "Defina el directorio de grabacion de los reportes de salida ($DIRPPAL/$REPODIR):"
		echo "Nombre del directorio actual de grabacion de los reportes de salida: $DIRPPAL/$REPODIR"
		pregunta "Desea modificarlo?"
		if [ $respuesta -eq 1 ] 
		then # permitir modificacion
			preguntarDirectorio
			REPODIR=$dirValidado
		fi
		$log I "Directorio de grabacion de los reportes de salida: $DIRPPAL/$REPODIR"
		echo "Directorio de grabacion de los reportes de salida: $DIRPPAL/$REPODIR"

		MostrarDatosInstalacion
		$log I "Estado de la instalacion: LISTA"
		echo "Estado de la instalacion: LISTA"
		$log I "Los datos ingresados son correctos?"
		pregunta "Los datos ingresados son correctos?"
		if [ $respuesta -eq 1 ] 
		then # permitir instalacion
			instalado=1
		else
			clear
		fi
	done 
#**************************FIN DE CONFIGURACION DE INSTALACION****************************	
}

function verificarEstadoInstalacion
{
	if ! [ -z "$1" ]; then
		if [ -f $DIRPPAL/$BINDIR/"$1" ]; then
			$log A "El comando ya se encuentra instalado"
			echo "El comando ya se encuentra instalado"
			echo "Componentes faltantes: "
			$log I "Componentes faltantes: "

			if ! [ -f $DIRPPAL/$BINDIR/"IniciarU.sh" ]; then echo "*IniciarU.sh"; $log I "*IniciarU.sh ";fi
			if ! [ -f $DIRPPAL/$BINDIR/"DetectarU.sh" ]; then echo "*DetectarU.sh"; $log I "*DetectarU.sh ";fi
			if ! [ -f $DIRPPAL/$BINDIR/"ListarU.pl" ]; then echo "*ListarU.pl"; $log I "*ListarU.pl ";fi
			if ! [ -f $DIRPPAL/$BINDIR/"GrabarParqueU.sh" ]; then echo "*GrabarParqueU.sh"; $log I "*GrabarParqueU.sh ";fi
			if ! [ -f $DIRPPAL/$BINDIR/"StartD.sh" ]; then echo "*StartD.sh"; $log I "*StartD.sh ";fi
			if ! [ -f $DIRPPAL/$BINDIR/"StopD.sh" ]; then echo "*StopD.sh"; $log I "*StopD.sh ";fi	
			$log A "Fin de la instalacion"
			echo "Fin de la instalacion"
			exit 0;
		fi 
	fi

	if [ ! -d $DIRPPAL/$BINDIR ]; then
		echo "Hubo un error en la instalacion, el directorio $BINDIR no existe"
	else
		cont=0
		if [ -f $DIRPPAL/$BINDIR/"IniciarU.sh" ]; then cont=$[ $cont + 1 ]; fi
		if [ -f $DIRPPAL/$BINDIR/"DetectarU.sh" ]; then cont=$[ $cont + 1 ]; fi
		if [ -f $DIRPPAL/$BINDIR/"ListarU.pl" ]; then cont=$[ $cont + 1 ]; fi
		if [ -f $DIRPPAL/$BINDIR/"GrabarParqueU.sh" ]; then cont=$[ $cont + 1 ]; fi
		if [ -f $DIRPPAL/$BINDIR/"StopD.sh" ]; then cont=$[ $cont + 1 ]; fi
		if [ -f $DIRPPAL/$BINDIR/"StartD.sh" ]; then cont=$[ $cont + 1 ]; fi
		
		if [ $cont -lt 6 ]; then
			$log I "Componentes Existentes:"			
			echo "Componentes Existentes:"
			echo ""
			$log I "Directorio de instalacion de los ejecutables: $BINDIR"
			echo "Directorio de instalacion de los ejecutables: $BINDIR"
			archivos=$(ls -l -Q "$DIRPPAL/$BINDIR"| grep '"$' | sed -e"s/\"\{1,\}/;/g" | cut -f2 -d';')
			archivos=$(echo $archivos)	
			echo "Lista de archivos: $archivos"
			$log I "Lista de archivos: $archivos"	
			$log I "Directorio de instalacion de los archivos maestros: $MAEDIR"
			echo "Directorio de instalacion de los archivos maestros: $MAEDIR"
			archivos=$(ls -l -Q "$DIRPPAL/$MAEDIR"| grep '"$' | sed -e"s/\"\{1,\}/;/g" | cut -f2 -d';')
			archivos=$(echo $archivos)	
			echo "Lista de archivos: $archivos"
			$log I "Lista de archivos: $archivos"		
			echo "Componentes faltantes: "
			$log I "Componentes faltantes: "

			if ! [ -f $DIRPPAL/$BINDIR/"IniciarU.sh" ]; then echo "*IniciarU.sh"; $log I "*IniciarU.sh ";fi
			if ! [ -f $DIRPPAL/$BINDIR/"DetectarU.sh" ]; then echo "*DetectarU.sh"; $log I "*DetectarU.sh ";fi
			if ! [ -f $DIRPPAL/$BINDIR/"ListarU.pl" ]; then echo "*ListarU.pl"; $log I "*ListarU.pl ";fi
			if ! [ -f $DIRPPAL/$BINDIR/"GrabarParqueU.sh" ]; then echo "*GrabarParqueU.sh"; $log I "*GrabarParqueU.sh ";fi
			if ! [ -f $DIRPPAL/$BINDIR/"StartD.sh" ]; then echo "*StartD.sh"; $log I "*StartD.sh ";fi
			if ! [ -f $DIRPPAL/$BINDIR/"StopD.sh" ]; then echo "*StopD.sh"; $log I "*StopD.sh ";fi			
		
			echo "Estado de la instalacion: INCOMPLETA"
			$log I "Estado de la instalacion: INCOMPLETA"
			
			if [ -z "$1" ]; then
				$log I "Desea completar la instalacion?"
				pregunta "Desea completar la instalacion?"
			else
				$log I "Desea instalar el componente?"
				pregunta "Desea instalar el componente?"
			fi			
			if [ $respuesta -eq 0 ] 
			then
				clear
				echo "Proceso de instalacion cancelado"
				$log I "Proceso de instalacion cancelado"
				exit 0
			fi
		else
			clear;
			
			$log I "Libreria del sistema: $CONFDIR"
			echo "Libreria del sistema: $CONFDIR"
			archivos=$(ls -l -Q "$CONFDIR"| grep '"$' | sed -e"s/\"\{1,\}/;/g" | cut -f2 -d';')	
			archivos=$(echo $archivos)		
			$log I "Lista de archivos : $archivos"
			echo "Lista de archivos : $archivos"

			$log I "Directorio de instalacion de los ejecutables: $BINDIR"
			echo "Directorio de instalacion de los ejecutables: $BINDIR"
			archivos=$(ls -l -Q "$DIRPPAL/$BINDIR"| grep '"$' | sed -e"s/\"\{1,\}/;/g" | cut -f2 -d';')	
			archivos=$(echo $archivos)		
			$log I "Lista de archivos : $archivos"
			echo "Lista de archivos : $archivos"

			$log I "Directorio de instalacion de los archivos maestros: $MAEDIR"
			echo "Directorio de instalacion de los archivos maestros: $MAEDIR"
			archivos=$(ls -l -Q "$DIRPPAL/$MAEDIR"| grep '"$' | sed -e"s/\"\{1,\}/;/g" | cut -f2 -d';')	
			archivos=$(echo $archivos)		
			$log I "Lista de archivos : $archivos"
			echo "Lista de archivos : $archivos"

			$log I "Directorio de arribo de archivos externos: $ARRIDIR"
			echo "Directorio de arribo de archivos externos: $ARRIDIR"
			
			$log I "Directorio de grabacion de los archivos externos rechazados: $RECHDIR"
			echo "Directorio de grabacion de los archivos externos rechazados: $RECHDIR"
			
			$log I "Directorio de grabacion de los logs de auditoria: $LOGDIR"
			echo "Directorio de grabacion de los logs de auditoria: $LOGDIR"

			$log I "Directorio de grabacion de los reportes de salida: $REPODIR"
			echo "Directorio de grabacion de los reportes de salida: $REPODIR"
	
			$log I "Estado de la instalacion: COMPLETA"
			echo "Estado de la instalacion: COMPLETA"

			$log I "Proceso de instalacion cancelado"
			echo "Proceso de instalacion cancelado"

			exit 0;
		fi
	fi
}

function crearDirectorio
{
	path=""
	OIFS=$IFS
	IFS="/"
	arr=($1)


	for i in ${arr[*]};  do
		path=$path$i;
		if ! [ -d "$path" ]; then
			mkdir "$path"		
		fi
		path=$path/;
	done

	IFS=$OIFS
	unset path
}

function crearEstructuras
{
	#***Se crean las estructuras de directorio requeridas***
		clear
		echo "Creando Estructuras de directorio. . . ."
		$log I "Creando Estructuras de directorio. . . ."
		echo ""
		
		#Creamos un array con todos los nuevos directorios a crear
		declare -a DIRECTORIOS
		DIRECTORIOS=( $BINDIR $MAEDIR $ARRIDIR $RECHDIR $LOGDIR $REPODIR inst_recibidas inst_ordenadas inst_rechazadas inst_procesadas parque_instalado )
		for i in ${DIRECTORIOS[*]} 
		do
			#Se crean los directorios
			echo "$i"
			$log I "$i"
			crearDirectorio $i
		done
}

function moverArchivos
{
	echo "Instalando Archivos Maestros."
	$log I "Instalando Archivos Maestros."

	if ! [ -f "$DIRPPAL/$MAEDIR/prod.mae" ]; then cp "$dirInst/prod.mae" "$DIRPPAL/$MAEDIR"; fi
	if ! [ -f "$DIRPPAL/$MAEDIR/sucu.mae" ]; then cp "$dirInst/sucu.mae" "$DIRPPAL/$MAEDIR"; fi
	if ! [ -f "$DIRPPAL/$MAEDIR/cli.mae" ]; then cp "$dirInst/cli.mae" "$DIRPPAL/$MAEDIR"; fi

	echo "Instalando Programas y Funciones."
	$log I "Instalando Programas y Funciones."

	if ! [ -f "$BINDIR/LoguearU.sh" ]; then
		cp "$dirInst/LoguearU.sh" "$DIRPPAL/$BINDIR"
	fi

	if ! [ -f "$BINDIR/MoverU.sh" ]; then
		cp "$dirInst/MoverU.sh" "$DIRPPAL/$BINDIR"
	fi

	if ! [ -f "$BINDIR/MirarU.sh" ]; then
		cp "$dirInst/MirarU.sh" "$DIRPPAL/$BINDIR"
	fi

	if [ -z "$1" ]; then

		if ! [ -f "$DIRPPAL/$BINDIR/IniciarU.sh" ]; then
			cp "$dirInst/IniciarU.sh" "$DIRPPAL/$BINDIR"
		fi
	
		if ! [ -f "$DIRPPAL/$BINDIR/DetectarU.sh" ]; then
			cp "$dirInst/DetectarU.sh" "$DIRPPAL/$BINDIR"
		fi

		if ! [ -f "$DIRPPAL/$BINDIR/StopD.sh" ]; then
			cp "$dirInst/StopD.sh" "$DIRPPAL/$BINDIR"
		fi

		if ! [ -f "$DIRPPAL/$BINDIR/StartD.sh" ]; then
			cp "$dirInst/StartD.sh" "$DIRPPAL/$BINDIR"
		fi
		
		if ! [ -f "$DIRPPAL/$BINDIR/ListarU.pl" ]; then
			cp "$dirInst/ListarU.pl" "$DIRPPAL/$BINDIR"
		fi
	
		if ! [ -f "$DIRPPAL/$BINDIR/GrabarParqueU.sh" ]; then
			cp "$dirInst/GrabarParqueU.sh" "$DIRPPAL/$BINDIR"
		fi
	else
		if ! [ -f "$DIRPPAL/$BINDIR/$1" ]; then
			cp "$dirInst/$1" "$DIRPPAL/$BINDIR"
		fi
	fi
}

function actualizarArchivoConf
{
	USER=`whoami`
	DATE=`date +%F`
	TIME=`date +%R`

	echo "Actualizando la configuracion del sistema."
	$log I "Actualizando la configuracion del sistema."	
	if [ ! -f "$CONFDIR/$archConf" ]; then
		touch "$CONFDIR/$archConf"
		echo "GRUPO=$GRUPO=$USER=$DATE=$TIME
ARRIDIR=$ARRIDIR=$USER=$DATE=$TIME
RECHDIR=$RECHDIR=$USER=$DATE=$TIME
BINDIR=$BINDIR=$USER=$DATE=$TIME
MAEDIR=$MAEDIR=$USER=$DATE=$TIME
REPODIR=$REPODIR=$USER=$DATE=$TIME
LOGDIR=$LOGDIR=$USER=$DATE=$TIME
LOGEXT=$LOGEXT=$USER=$DATE=$TIME
LOGSIZE=$LOGSIZE=$USER=$DATE=$TIME
DATASIZE=$DATASIZE=$USER=$DATE=$TIME










" > $CONFDIR/$archConf
	
	fi
}

function completarInstalacion
{
	crearEstructuras
	moverArchivos
	actualizarArchivoConf
}

function instalarComando
{
	comand="$1"
	crearEstructuras
	moverArchivos "$1"
	actualizarArchivoConf
}

#*****************************************************FIN Funciones utilizadas***************************************


#*****************************************INICIO PROGRAMA************************************************************

echo	"********************************************************
*  Bienvenido al Asistente de instalacion del practico *
********************************************************"
echo 	"*********************************************************
*	TP SO7508 1er cuatrimestre 2012.		*
*	Tema U Copyright (c) Grupo 06			*	
*********************************************************"

#verifico que el directorio $dirInst exista
if [ ! -e "$dirInst" ]
then
	echo ""
	echo "El directorio $dirInst no existe"
	echo 'No se puede iniciar la instalación.'
	echo  'Por favor lea el archivo README.txt y vuelva a realizar la instalación'
	echo ""
	exit 1
fi

#Creo el directorio /confdir
if [ ! -e "$CONFDIR" ] 
then	
	mkdir $CONFDIR	
fi

#Verifico que existan todos los archivos necesarios para la instalacion
cd $dirInst 
for ((i=0;i<${#ARCH_OBL[*]};i++)); do
	if [ ! -e ${ARCH_OBL[$i]} ] 
	then	
		echo ""
		echo "No se encontro el archivo ${ARCH_OBL[$i]} necesario para realizar la instalacion" 
		echo ""
		echo $msgError
		echo "Verifique que ${ARCH_OBL[$i]} exista"
		echo ""
		exit 2
	fi
done
cd ..

#Creo el archivo /InstalarU.log

if [ ! -e "$CONFDIR/$arch_log_i" ] 
then	
	touch "$CONFDIR/$arch_log_i"	
fi

#Verificar nombre del parametro si existe
if ! [ -z "$1" ]; then
	validarParametro "$1"
fi

parametro="$1"

#inicio ejecucion
$log I "Inicio de Ejecucion"

if [ -e "$CONFDIR/$archConf" ]
then
	leerVariablesDeConfiguracion "$CONFDIR/$archConf"
	verificarEstadoInstalacion "$parametro"
	validarPerl
	MostrarDatosInstalacion
	confirmarInicioInstalacion
else
	validarPerl
	cargarParametrosInstalacion
	confirmarInicioInstalacion
fi

if [ $instalar -eq 1 ]
then
	if [ -z "$parametro" ]; then		
		completarInstalacion
	else
		instalarComando "$parametro"
	fi
fi

echo "Instalacion concluida."
$log I "Instalacion concluida."

