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
		if [ $nombre == $1 ]; then
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

	#$1 = msj informativo
	#$2 = msj porque
	export user=$(whoami)
	fechaHora=`date +"%m/%d/%y %H:%M"`
	usuario=$user
	comando="mover"
	msj=$1
	porque=$2
	msjSalida=$fechaHora";"$usuario";"$comando";"$msj";"$porque
	echo $msjSalida
}

###############################################################################################
###############################CODIGOS DE ERROR################################################
###############################################################################################
cantParametros=$#
codigoError=0
if [ $cantParametros -ge 4 ]; then
	#echo "Demasiados argumentos para buscar (maximo 3)"
	codigoError=3	
fi

existeDirDestino=$(validarExistenciaDirDestino $2)
if [ $existeDirDestino -eq 0 ] ; then 	
	#echo "El directorio '"$2"' no existe, emito codigo de error 2"
	codigoError=2
fi

existeOriginal=$(validarExistenciaArchOrig $1)
if [ $existeOriginal -eq 0 ] ; then 	
	#echo "El Archivo '"$1"' no existe, emito codigo de error 1"
	codigoError=1
fi
###############################################################################################
###############################################################################################
###############################################################################################
#//==========================================================================================//
###############################################################################################
##############################COPIADO Y EMISION DE MSJ DE SALIDA###############################
###############################################################################################

if [ $codigoError -eq 0 ]; then
	#####COPIADO#####
	nombreOriginal=`basename $1`
	#obtengo el ultimo numero de la secuencia y le concateno el siguiente
	numeroSec=$(obtenerUltimaSecuencia $nombreOriginal $2)		
	nombreNuevo=$nombreOriginal"."$numeroSec
	mv $1 $2$nombreNuevo
fi





#####MSJ SALIDA#####
case $codigoError in
	"0")
		msjSalida=$(crearMsjLog "Movimiento Correcto" "Se movio '"$1"' como '"$2$nombreNuevo"'")
		;;
	"1")
		msjSalida=$(crearMsjLog "Movimiento Incorrecto" "El Archivo '"$1"' no existe")
		;;
	"2")
		msjSalida=$(crearMsjLog "Movimiento Incorrecto" "El directorio '"$2"' no existe")
		;;
	"3")
		msjSalida=$(crearMsjLog "Movimiento Incorrecto" "Demasiados argumentos para buscar (maximo 3)")
		;;
esac
echo $msjSalida


exit 0










