#!/bin/bash
OLD_IFS=$IFS
IFS='
'
comando=""
cant_lineas_desde_final=0
inicio=1
filtro_default="[A,E,I,E,SE]"
filtro_tipo=$filtro_default
filtro_string=""
filtro_fecha=""
archivo_output=""

#Cod. de error
ERROR_PARAM=1
ERROR_TIPO_MENS=2
ARCH_INEXISTENTE=3
DIR_INEXISTENTE=4
ERROR_MAX_LINEAS=5
if [ -z $LOGDIR ] || [ -z $LOGEXT ] || [ -z $GRUPO ]; then
	DIR_LOG=../logdir
	LOGEXT=log
else
	DIR_LOG=$GRUPO'/'$LOGDIR
fi

function mostrar_ayuda {
	echo
	echo "Uso: $nombre -<opcion> -c [comando] parametro"
	echo "	-h: muestra ayuda"
	echo "	-c <comando>: comando a buscar (obligatorio)"
	echo "	-t <[I-A-E-SE]>: tipo de mensaje"
	echo "	-s <cadena>: cadena que deben contener las lineas del resultado"
	echo "	-n <num>: ultimas n lineas a leer del archivo de log."
	echo "	-o <archivo>: especifica la ruta del archivo de salida para guardar la consulta."
	echo
}

patron="^-[0-9].*$"

while (( $# ))
do
	case $1 in
		-h ) mostrar_ayuda
			 exit 0 ;;
		-c ) comando=$2
			echo "comando: $2"
	;;
		-t ) filtro_tipo=$2 
	;;
		-s ) filtro_string="$2"
			echo "Se he indicado mostrar mensajes que conetengan el string '"$filtro_string"'." 
	;;
		-o ) archivo_output=$2
			echo "Archivo de salida $2..."
 	;;
		-[0-9]*)
			echo $1 | grep --silent "^-[0-9].*$"
			if [ $? -eq 0 ] ; then
				cant_lineas_desde_final=$(echo $1 | sed s/'-'//)
			fi 
		;;	
		"") mostrar_ayuda
			exit $ERROR_PARAM
		;; 
	esac	
	shift
done

#Verificar existencia de archivos
filename="$comando.$LOGEXT"
filepath="$DIR_LOG/$filename"
if [ ! -f $filepath ]; then
	echo "El archivo de log $filepath no existe." >&2
	exit $ARCH_INEXISTENTE
fi

if [ "$archivo_output" != "" ] && [ ! -f $archivo_output ] ; then
	touch $archivo_output
fi

if [ "$filtro_tipo" != "$filtro_default" ] && [ "$filtro_tipo" != "I" ] && [ "$filtro_tipo" != "A" ] && [ "$filtro_tipo" != "E" ] && [ "$filtro_tipo" != "SE" ]
then
	echo "Tipo de mensaje inexistente" >&2
	mostrar_ayuda
	exit $ERROR_TIPO_MENS
fi

#si excede la cantidad de lineas del archivo, se muestran todas
cantidad_lineas_total=$(cat $filepath | wc -l)


if [ $cant_lineas_desde_final -ne 0 ]; then
	if [ $cant_lineas_desde_final -gt $cantidad_lineas_total ]; then
		cant_lineas_desde_final=$cantidad_lineas_total
	fi
fi

if [ $cant_lineas_desde_final -ne 0 ] ; then
	let inicio=inicio+"${cantidad_lineas_total}"
	let inicio=inicio-"${cant_lineas_desde_final}"
fi	

#con el sed selecciono las últimas n lineas#
for linea in `sed -n $inicio,"$cantidad_lineas_total"p $filepath`;
do
	
	if [ "$filtro_tipo" == "$filtro_default" ]
	then
		echo $linea | grep ".*$filtro_string.*"
		if [ $archivo_output ]
		then
			echo $linea | grep ".*$filtro_string.*" >> $archivo_output
		fi

	else
		echo $linea | grep ".*\[$filtro_tipo\].*$filtro_string.*"
		if [ $archivo_output ]
		then
			echo $linea | grep ".*\[$filtro_tipo\].*$filtro_string.*" >> $archivo_output
		fi
	fi
done

IFS=$OLD_IFS

exit 0


