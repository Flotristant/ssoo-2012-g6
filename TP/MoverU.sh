#parametro1 : Origen
#parametro2 : Destino
#parametro3 : Comando que lo invoca

function validarExistenciaArchOrig
{
	#$1 path + nombre del archivo origen

	if [ -f $1 ]; then
		existe=1
	else
		existe=0
	fi
	echo $existe
}

function validarExistenciaDirDestino
{
	#$1 = archivo origen
	#$2 = directorio destino

	#Primero me quedo con el nombre de archivo que me pasan
	#basename quita todo lo relativo a un directorio, entonces me quedo con el nombre del archivo solamente
	directorioDestino=$1
	
	if [ -d $directorioDestino ]; then
		existe=1
	else 
		existe=0
	fi	
	
	echo $existe
	
}

function obtenerUltimaSecuencia
{
	#$2 = directorio destino
	#$1 = archivo original
	# '^'$1'[.][0-9].*' --> Me fijo que los archivos del directorio empiezen con el nombre del archivo Original
		#y esten seguidos por un . y luego un valor entre 0 y 9 n veces 
	lista=`ls $2 | grep '^'$1'[.][0-9].*'`
	#ls $2 | grep '^ando[.][0-9].*'
	#lista=`ls $2`
	length=`expr length $1`
	siguiente=`expr $length + 1`
	existe=0
	numero=0


	for i in $lista
	do 
		nombre=${i:0:length}
		if [ $nombre == $1 ] ; then
			existe=1
			#obtengo el numero de secuencia en el directorio y comparo si es mayor que la anterior
			#lo hago porque el archivo.100 no queda despues del archivo.20
			numeroDeArchivo=${i:$siguiente}			
			if [ $numeroDeArchivo -ge $numero ]; then
				numero=$numeroDeArchivo
			fi			
		fi
	done

	if [ $existe -eq 1 ]; then
		numero=`expr $numero + 1`
	fi	
	echo $numero
}

function crearMsjLog
{
	#crea el msj para loguear el movimiento

	#$1 = TIPO MENSAJE
	#$2 = MENSAJE
	msjSalida="moverU "$1" "$MENSAJE
	echo $msjSalida
}

###############################################################################################
###############################CODIGOS DE ERROR################################################
###############################################################################################
cantParametros=$#
codigoError=0
if [ $cantParametros -ne 2 ] && [ $cantParametros -ne 3 ]; then
	#echo "Demasiados argumentos para buscar (maximo 3)"
	codigoError=3	
	msj="Uso: [ARCHIVO ORIGEN] [DIRECTORIO DESTINO] [COMANDO]\n"
	msj=$msj"Mueve archivos de un directorio a otro creando historicos\n"
	msj=$msj"Cantidad de Parametros incorrecta "
	echo -e $msj
	exit $codigoError
fi




existeDirDestino=$(validarExistenciaDirDestino $2)
if [ $existeDirDestino -eq 0 ] ; then 	
	echo "El directorio '"$2"' no existe"
	codigoError=2
fi

existeOriginal=$(validarExistenciaArchOrig $1)
if [ $existeOriginal -eq 0 ] ; then 	
	echo "El Archivo '"$1"' no existe"
	codigoError=1
fi
###############################################################################################
###############################################################################################
###############################################################################################
#//==========================================================================================//
###############################################################################################
##############################COPIADO Y EMISION DE MSJ DE SALIDA###############################
###############################################################################################

#####MSJ SALIDA#####
chmod 777 LoguearU.sh

#Si esta definido el comando que me pasan 
#me fijo si llama al loguear
loguear=0
comando=$3
if [ ! -z $comando ]; then
	if [ -f $comando."sh" ]; then
		llamadasLoguearU=`grep -c 'LoguearU.sh' $comando."sh"`
		if [ $llamadasLoguearU -gt 0 ]; then
			loguear=1
		fi
	else
		echo -e "El archivo '"$comando.sh"' no existe" 
	fi

fi

if [ $loguear -eq 1 ]; then
	case $codigoError in
		"1")
			LoguearU.sh $comando  "SE" "El-Archivo-$1-no-existe-"
			;;
		"2")
			LoguearU.sh $comando  "SE" "El-directorio-$2-no-existe"
			;;
		
		
	esac
fi

if [ $codigoError -eq 0 ]; then
	#####COPIADO#####
	nombreOriginal=`basename $1`
	#obtengo el ultimo numero de la secuencia y le concateno el siguiente
	numeroSec=$(obtenerUltimaSecuencia $nombreOriginal $2)		
	nombreNuevo=$nombreOriginal"."$numeroSec
	mv $1 $2$nombreNuevo
	LoguearU.sh $comando "I" "Se-movio-$1-como-$2$nombreNuevo"
fi












