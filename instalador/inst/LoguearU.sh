#!/bin/bash
IFS_ANT=$IFS
IFS='
'

#####PARAMETROS######

#1 = COMANDO que llamo a loguear
#2 = TIPO DE MENSAJE 
#3 = MENSAJE

#####CODIGOS DE ERROR#####
errorCantParametros=1
errorTipoMsj=2

#####Valores defecto######
cantParametros=3

function obtenerDirectorioLog
{
	#El directorio de log puede venir por variable de ambiente o ser seteado por default
	if [ $1 = "/" ]; then
		log=../logdir
	else
		if [ ! -d $1 ]; then
			log=../logdir
		else
			log=$1
		fi
	fi
		echo $log
}

function obtenerExtensionArchivosLog
{
	#La extension puede venir por variable de ambiente o ser seteada por default
	if [ -z $1 ]; then
		extension=.log
	else
		extension=$1
	fi
	echo $extension
}

function obtenerMaximoTamanio
{
	#El tamanio maximo del archivo de log me puede venir por var de ambiente o seteada por default
	if [ -z $1 ]; then
		tamDato=`expr 100 \* 1024 \* 8`
	else
		tamDato=$1
	fi
	echo $tamDato
}


function msjDeError
{
		msj="Uso: $1 [COMANDO] [TIPO MENSAJE] [MENSAJE]\n"
		msj=$msj"Escribe en los archivos de logs\n"
		msj=$msj"Tipos de mensajes:\n"
		msj=$msj"I = Informativo \nA = Alerta \nE = error \nSE = Error Severo \n"
		msj=$msj"Error: "$2
		echo $msj
}

function loguear
{

	##Verifico tipo de msj
	if [ "$2" != "I" ] && [ "$2" != "A" ] && [ "$2" != "E" ] && [ "$2" != "SE" ]
	then
		msj=$(msjDeError $0 "Tipo de mensaje invalido: $2")
		echo -e $msj
		exit $ERROR_TIPO_MENS
	fi

	#Obtengo los directorios y la extension de los archivos
	if [ "$1" != "InstalarU" ]
	then
		dirlog=$(obtenerDirectorioLog "$GRUPO/$LOGDIR")
		extlog=$(obtenerExtensionArchivosLog $LOGEXT)
	else
		dirlog="$PWD/confdir";
		extlog=".log";
	fi
	#verifico la existencia de los directorios
	#Cada comando tiene un archivo de log	
	filename="$1$extlog"
	filepath="$dirlog/$filename"

	if [ -d $dirlog ] 
	then
		if [ ! -f $filepath ]
		then
			touch $filepath
		fi
	else
		#Creo el directorio si no existe
		mkdir $dirlog
		touch $filepath
	fi

	#Obtengo usuario,fecha 
	user=$(whoami)
	date=$(date +"%m-%d-%Y %T")
	
	#Escribo en el archivo
	echo "$user $date comando $1: [$2] $3" >> $filepath

	#obtengo el tamanio del archivo
	tamanioArchivo=$(stat -c%s "$filepath")
	let tamanioArchivo=($tamanioArchivo/1048576)	
	tamanioMaximo=$(obtenerMaximoTamanio $LOGSIZE)

	#Verifico el tamanio del archivo de log
	if [ $tamanioArchivo -gt $tamanioMaximo ]; then
		echo "$user $date comando $1: [A] ¡Log excedido!" >> $filepath 
		#Trunco el archivo
		file_lines=`cat $filepath | wc -l`
		file_lines=$(expr $file_lines / 2)
		sed -i 1,+${file_lines}d $filepath
	fi
}

##Valido Cantidad de parametros
if [ $# -ne $cantParametros ]; then
	msj=$(msjDeError $0 "Cantidad de parametros invalida, se recibieron $# parametros")
	echo -e $msj
	exit $errorCantParametros
fi

loguear $1 $2 $3



IFS=$IFS_ANT
exit 0

