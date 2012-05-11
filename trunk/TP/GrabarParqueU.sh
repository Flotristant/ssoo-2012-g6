#! /bin/bash

########################################
#		Comando GrabarParqueU.sh	   #	
#			Version 4.0 			   #
########################################



function estaCorriendoApp
{
	local DATO
	local CANT
	local temporal
	temporal="$GRUPO/temporales/temporal.concurrencia"
	ps -C "GrabarParqueU.sh"|grep 'GrabarParqueU' > "$temporal"
	DATO=$?
	local activo=1
	if [ ${DATO} -eq 0 ]; then
		CANT=$(cat "$temporal"|grep -c 'GrabarParqueU')
		if [ $CANT -eq 1 ] ; then
			activo=0
		fi
	fi
	if [ -f "$temporal" ] ; then
		rm "$GRUPO/temporales/temporal.concurrencia"
	fi
	return $activo
}

function estaCorriendoApp2
{
	OLDIFS=$IFS
	IFS='
	'	

	local PIDS
	local cant	
	local activo=1
	
	PIDS=$(pgrep 'GrabarParqueU')
	for i in ${PIDS}
	do
		let cant=cant+1
	done

	echo "cant: $cant ids: $PIDS"

	if [ $cant -eq 1 ] ; then
		activo=0
	fi
	
	IFS=$OLDIFS
	return $activo	
}

function ordenarArchivo
{
	local SEPARADOR=','
	sort -t $SEPARADOR -k 1,1n -k 2.7,2.10n -k 2.3,2.4 -k 2.1,2.2n -k 3,3n -k 5,5r $INST_RECIBIDAS'/'$1 > $ORDDIR'/'$1

}

#$1 nombre archivo ordenado
function procesarArchivoOrdenado 
{
	#validar bloque: un registro cabecera y un registro detalle
	OLDIFS= $IFS
	IFS='
	'

	local NOMBRE_ARCHIVO=$( basename $1 )
	#echo $NOMBRE_ARCHIVO
	local ARCHIVO_RECHAZADOS=$INST_RECHAZADAS'/'$NOMBRE_ARCHIVO
	local ARCHIVO_ACEPTADOS=$INSTPROCESADAS'/'$NOMBRE_ARCHIVO

	#echo $ARCHIVO_RECHAZADOS
	#echo $ARCHIVO_ACEPTADOS

	local cont=0
	local id_cliente=0
	local id_cliente_anterior=0
	local primer_registro=1
	local i

	for i in `cat $ORDDIR'/'$1`
	do
		let CANT_REGISTROS_LEIDOS=CANT_REGISTROS_LEIDOS+1
		id_cliente=$(echo $i | cut -d ',' -f 1)
		#echo "procesando $id_cliente"
		if [ $primer_registro -eq 1 ]; then
			echo "$i" >> "$temporal"
			let cont=cont+1
			primer_registro=0
		else
			if [ $id_cliente -eq $id_cliente_anterior ]; then
				echo "$i" >> "$temporal"
				let cont=cont+1
			else
				#echo "ids diferentes: $id_cliente $id_cliente_anterior"
				if [ $cont -ge 2 ] ; then
					procesarBloquesCliente $temporal $NOMBRE_ARCHIVO			
				else
					let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+1	
					#echo "se rechaza bloque ($id_cliente_anterior) por cantidad invalida de registros: $cont"
					cat $temporal >> "$ARCHIVO_RECHAZADOS"
					echo "***archivo temporal***"
					cat $temporal
					rm $temporal
				fi
				cont=1
				rm $temporal
				echo "$i" >> "$temporal"	
			fi
		fi
		id_cliente_anterior=$id_cliente
	done
	#valido ultimo bloque
	#echo "VALIDACION ULTIMO BLOQUE..."
	if [ $cont -ge 2 ] ; then
		procesarBloquesCliente $temporal $NOMBRE_ARCHIVO			
	else
		let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+1	
		#echo "se rechaza bloque por contener un solo registro: $cont"
		cat $temporal >> "$ARCHIVO_RECHAZADOS"
	fi
	if [ -e $temporal ]; then
		rm $temporal
	fi

	IFS=$OLDIFS		
}

function validarCantidadCampos
{
	#grep retorna 0 en caso de exito, 1 en caso contrario, 2 en caso de error
	VALIDA=`echo $1 | grep --silent  '^[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*$'`
	return $?	
}


#$1: registro
function validarCabecera 
{
	echo $1 | grep --silent  ',"Y",[^,]*$'
	return $?	
}

function validarDetalle
{
	echo $1 | grep --silent  ',"N",[^,]*$'
	return $?
}

#$1: mensje
function grabarMensajeError
{
	TIPO="E"
	local mensaje=$1
	LoguearU.sh $NOMBRE $TIPO "$mensaje"
}

#$1 archivo con bloques de un cliente
#$2 nombre archivo que se esta procesando
function procesarBloquesCliente
{
	local archivo=$1
	local nombre_archivo=$2
	local es_el_primero=1
	local CABECERA
	local DETALLE
	local j
	
	#voy leyendo de a dos registros (un bloque) y valido
	for j in `cat $archivo`
	do
		validarCantidadCampos $j
		if [ $? -eq 0 ]; then
			if [ $es_el_primero -eq 1 ]; then
				validarCabecera $j
				if [ $? -eq 0 ]; then
					#echo "leo la primera cabecera: $j"
					CABECERA=$j
					es_el_primero=0
					leyo_cabecera=1
				else
					#echo "se rechaza porque es el primero y no es cabecera: $j"
					echo $j >> "$ARCHIVO_RECHAZADOS"	
					let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+1
					mens="se encontro detalle sin cabecera"
					grabarMensajeError $mens	
				fi		
			else			
				if [ -z CABECERA ]; then
					#echo "validando cabecera..error, aca no deberia entrar nunca, registro: $j"
					validarCabecera $j
					if [ $? -eq 0 ]; then
						CABECERA=$j
					else
						echo $j >> "$ARCHIVO_RECHAZADOS"
						let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+1	
					fi	
				else
					if [ -z $DETALLE ] ; then
						#echo "validando si es detalle: $j"
						validarDetalle $j
						if [ $? -eq 0 ]; then
							DETALLE=$j
							#echo "es detalle: $j"
							leyo_detalle=1
						else
							#si espero leer un detalle y me encuentro con una nueva cabecera, me quedo con esa
							#echo "no es detalle, validando si es cabecera: $j"
							validarCabecera $j
							if [ $? -eq 0 ]; then
								#echo "es cabecera, se rechaza la anterior ($CABECERA)"
								echo $CABECERA >> "$ARCHIVO_RECHAZADOS"
								let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+1
								CABECERA=$j
								mens="se encontro cabecera sin detalle"
								grabarMensajeError $mens
							else
								#echo "no es cabecera ni detalle"
								#no es cabecera ni detalle
								echo $j >> "$ARCHIVO_RECHAZADOS"	
								let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+1
								mens="el registro no es cabecera ni detalle"
								grabarMensajeError $mens
							fi	
						fi 
					else
						#echo "ya tengo detalle,validando si el leido es detalle"
						validarDetalle $j
						if [ $? -eq 0 ]; then
							#echo "leo un detalle y ya habia leido uno, lo rechazo"
							#si leo un detalle y ya habia leido uno, lo rechazo
							echo $j >> "$ARCHIVO_RECHAZADOS"	
							let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+1	
							mens="se encontro detalle sin cabecera"
							grabarMensajeError $mens
						else
							#echo "ya tengo detalle,el leido no es detalle, valido que sea cabecera"
							validarCabecera $j
							if [ $? -eq 0 ]; then
								#echo "leo una cabecera y ya tengo cabecera y detalle, proceso los datos (se envia a validar y luego a grabar)"
								#si leo una cabecera y ya tengo cabecera y detalle, proceso los datos (se envia a validar y luego a grabar):
								Validar $CABECERA $DETALLE 
								#echo "reemplazo con la nueva cabecera ("$j") y borro el detalle"
								CABECERA=$j
								DETALLE=""
							else
								#echo "no es cabecera ni detalle"
								#no es cabecera ni detalle
								echo $j >> "$ARCHIVO_RECHAZADOS"
								let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+1	
								mens="el registro no es cabecera ni detalle"
								grabarMensajeError $mens
							fi
						fi
					fi
				fi
			fi
		else
			#echo "se rechaza el registro por cantidad invalida de campos: $j"
			echo $j >> "$ARCHIVO_RECHAZADOS"
			let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+1	
			mens="se rechaza el registro por cantidad invalida de campos"
			grabarMensajeError $mens
		fi		
	done
	#echo "validacion del ultimo bloque.."
	if [ ! -z $CABECERA ] && [ ! -z $DETALLE ]; then
		#echo "validando: $CABECERA $DETALLE"
		Validar $CABECERA $DETALLE
	else
		if [ ! -z $CABECERA ]; then
			echo $CABECERA >> "$ARCHIVO_RECHAZADOS"
			let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+1
			mens="se encontro cabecera sin detalle"
			grabarMensajeError $mens
		fi
		if [ ! -z $DETALLE ]; then
			#echo "**ERROR ESTO NO DEBERIA SUCEDER**"
			echo $DETALLE >> "$ARCHIVO_RECHAZADOS"
			let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+1	
			mens="se encontro detalle sin cabecera"
			grabarMensajeError $mens
		fi
	fi

	return 0
}

# $1: cabecera $2: detalle

function Validar
{
	local CABECERA=$1
	local DETALLE=$2
	validarRegistro $CABECERA
	if [ $? -eq 0 ]; then
		validarRegistro $DETALLE
		if [ $? -eq 0 ]; then
			grabarBloque $CABECERA $DETALLE $nombre_archivo
			let CANT_REGISTROS_GRABADOS=CANT_REGISTROS_GRABADOS+1	
		else
			#echo "no valida el detalle: $DETALLE"
			echo $CABECERA >> "$ARCHIVO_RECHAZADOS"
			echo $DETALLE >> "$ARCHIVO_RECHAZADOS"
			let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+2		
			no_valida=1
		fi
	else
		#echo "no valida la cabecera: $CABECERA"
		echo $CABECERA >> "$ARCHIVO_RECHAZADOS"
		echo $DETALLE >> "$ARCHIVO_RECHAZADOS"
		let CANT_REGISTROS_INVALIDOS=CANT_REGISTROS_INVALIDOS+2
		no_valida=1
	fi
}

# $1 registro
function validarRegistro
{
	local es_valido=0
	
	#valido a nivel de campo
	ID_USUARIO=$( echo $1 | cut -d ',' -f 1 )
	FECHA_OP=$( echo $1 | cut -d ',' -f 2 )
	ID_PLAN=$( echo $1 | cut -d ',' -f 3 )
	ID_CLASE_SERVICIO=$(echo $1 | cut -d ',' -f 4)
	ID_PROD=$( echo $1 | cut -d ',' -f 6)

	if [ -z $ID_USUARIO ]; then
		TIPO="E"
		MENSAJE="campo 'id usuario' no informado en registro:$1"
		LoguearU.sh $NOMBRE $TIPO "$MENSAJE"
		#echo "campo id_usuario no informado: $1"
		es_valido=1
	else
		buscarCliente $ID_USUARIO
		if [ $? -ne 0 ]; then
			es_valido=1
			TIPO="E"
			MENSAJE="cliente inexistente($ID USUARIO) en registro:$1"
			LoguearU.sh $NOMBRE $TIPO "$MENSAJE"
			#echo "cliente inexistente: $ID_USUARIO ( $1 )"
		fi
	fi

	if [ -z $FECHA_OP ]; then
		TIPO="E"
		MENSAJE="campo 'fecha' no informado en registro:$1"
		LoguearU.sh $NOMBRE $TIPO "$MENSAJE"
		#echo "campo fecha no informado: $1"
		es_valido=1
	else
		validarFecha $FECHA_OP
		if [ $? -ne 0 ]; then
			TIPO="E"
			MENSAJE="campo 'fecha de operacion' invalida en registro:$1"
			LoguearU.sh $NOMBRE $TIPO "$MENSAJE"
			#echo "fecha de operacion invalida: $1"
			es_valido=1
		fi
	fi

	if [ -z $ID_PLAN ] || [ -z $ID_CLASE_SERVICIO ] || [ -z $ID_PROD ]; then
		TIPO="E"
		MENSAJE="algun campo de producto no informado en registro:$1"
		LoguearU.sh $NOMBRE $TIPO "$MENSAJE"
		#echo "campos de producto no informados: $1"
		es_valido=1
	else
		validarProducto $ID_PLAN $ID_CLASE_SERVICIO $ID_PROD
		if [ $? -ne 0 ]; then
			TIPO="E"
			MENSAJE="producto inexistente en registro:$1"
			LoguearU.sh $NOMBRE $TIPO "$MENSAJE"
			#echo "producto inexistente: $1"
			es_valido=1
		fi
	fi
	return $es_valido
}

# $1 id_cliente
function buscarCliente
{
	CLIENTE=`cut -d ',' -f 1,4 $GRUPO'/'$MAEDIR'/''cli.mae' | grep $1`
	return $?
}

# $1 fecha en formato: dd/mm/aaaa
function validarFecha
{
	local dia_registro=$( echo $1 | cut -d '/' -f 1)
	local mes_registro=$( echo $1 | cut -d '/' -f 2)
	local anio_registro=$( echo $1 | cut -d '/' -f 3)
	local dia=$( date '+%d' )
	local mes=$( date '+%m' )
	local anio=$( date '+%Y' )
	
	if [ $anio_registro -eq $anio ]; then
		if [ $mes_registro -eq $mes ]; then
			if [ $dia_registro -le $dia ]; then
				return 0		
			fi
		else 
			if [ $mes_registro -lt $mes ]; then
				return 0
			fi	
		fi
	else
		if [ $anio_registro -lt $anio ]; then
			return 0
		fi
	fi
	return 1
}

# $1: id plan $2: id clase de servicio $3 id item producto
function validarProducto
{
	local codigo=$1','$2','$3
	`cut -d ',' -f 3,5,8 $GRUPO'/'$MAEDIR'/''prod.mae' | grep --silent ${codigo}`
	return $?
}

# $1 : registro cabecera
# $2 : registro detalle
# $3 : nombre archivo
function grabarBloque 
{
	local cabecera=$1
	local detalle=$2
	local nombre_archivo=$3
	
	local nombre_sin_punto=`echo ${nombre_archivo%.*}`
	local id_sucursal=$(echo $nombre_sin_punto | cut -d '-' -f 2 )
	local id_cliente=$(echo $cabecera | cut -d ',' -f 1)
	
	local ID_PLAN=$( echo $cabecera | cut -d ',' -f 3 )
	local ID_CLASE_SERVICIO=$(echo $cabecera | cut -d ',' -f 4)
	local ID_PROD=$( echo $cabecera | cut -d ',' -f 6)

	local nombre_producto=$( obtenerNombreProducto $ID_PLAN $ID_CLASE_SERVICIO $ID_PROD )
	local item_name_cabecera=$( obtenerItemName $ID_PLAN $ID_CLASE_SERVICIO $ID_PROD )

	local ID_PLAN=$( echo $detalle | cut -d ',' -f 3 )
	local ID_CLASE_SERVICIO=$(echo $detalle | cut -d ',' -f 4)
	local ID_PROD=$( echo $detalle | cut -d ',' -f 6)

	local item_name_detalle=$( 	obtenerItemName $ID_PLAN $ID_CLASE_SERVICIO $ID_PROD )
	nombre_producto=$( echo $nombre_producto | sed 's/"//g' )

	echo $id_sucursal','$id_cliente','$item_name_cabecera','$item_name_detalle >> $PARQUEDIR'/'$nombre_producto
}

# $1 : registro
function obtenerNombreProducto
{
	local ID_PLAN=$1
	local ID_CLASE_SERVICIO=$2
	local ID_PROD=$3

	local codigo=$ID_PLAN','$ID_CLASE_SERVICIO','$ID_PROD
	local product_name=`cut -d ',' -f 2,3,5,8 $GRUPO'/'$MAEDIR'/''prod.mae' | grep ${codigo} | cut -d ',' -f 1`
	echo $product_name
}

# $1 : registro
function obtenerItemName
{
	local ID_PLAN=$1
	local ID_CLASE_SERVICIO=$2
	local ID_PROD=$3

	local codigo=$ID_PLAN','$ID_CLASE_SERVICIO','$ID_PROD
	local item_name=`cut -d ',' -f 3,5,8,9 $GRUPO'/'$MAEDIR'/''prod.mae' | grep ${codigo} | cut -d ',' -f 4`
	echo $item_name
}

function mostrarCantidadRegistrosProcesados 
{
	#echo "cantidad de registros leidos: $CANT_REGISTROS_LEIDOS"
	#echo "cantidad de registros rechazados: $CANT_REGISTROS_INVALIDOS"
	#echo "cantidad de registros grabados en algun parque: $CANT_REGISTROS_GRABADOS"
	
	TIPO="I"
	MENSAJE="la cantidad de registros leidos es:$CANT_REGISTROS_LEIDOS"
	LoguearU.sh $NOMBRE $TIPO "$MENSAJE"
	MENSAJE="la cantidad de registros grabados en algun parque:$CANT_REGISTROS_GRABADOS"
	LoguearU.sh $NOMBRE $TIPO "$MENSAJE"
	MENSAJE="la cantidad de registros rechazados:$CANT_REGISTROS_INVALIDOS"
	LoguearU.sh $NOMBRE $TIPO "$MENSAJE"
	

	let TOTAL_DE_CONTROL=CANT_REGISTROS_GRABADOS*2
	let TOTAL_DE_CONTROL=TOTAL_DE_CONTROL+CANT_REGISTROS_INVALIDOS

	#echo "total de control: $TOTAL_DE_CONTROL"
	MENSAJE="el total de control es (rechazados + ( grabados en parque * 2 ) ):$TOTAL_DE_CONTROL"
	LoguearU.sh $NOMBRE $TIPO "$MENSAJE"

}

##VARIABLES DE CONTROL GLOBALES##
CANT_REGISTROS_LEIDOS=0
CANT_REGISTROS_INVALIDOS=0
CANT_REGISTROS_GRABADOS=0
TOTAL_DE_CONTROL=0
NOMBRE='GrabarParqueU'

#valido si ya esta corriendo
estaCorriendoApp2
estaCorriendo=$?
AMBIENTE_OK=0
if [ ${estaCorriendo} -eq 1 ] ; then
	#echo "el proceso ya esta corriendo"
	TIPO="SE"
	MENSAJE="el proceso ya esta corriendo"
	LoguearU.sh $NOMBRE $TIPO "$MENSAJE"
else
	if [ -z $ARRIDIR ] || [ -z $RECHDIR ] || [ -z $GRUPO ] || [ -z $MAEDIR ]; then
		AMBIENTE_OK=1
		TIPO='SE'
		MENSAJE="ambiente no inicializado"
		LoguearU.sh $NOMBRE $TIPO "$MENSAJE" 
	else
		AMBIENTE_OK=0
		temporal='/home/florencia/SSOO/grupo06/temporales/temp.temp'
		ORDDIR=$GRUPO'/inst_ordenadas'
		PARQUEDIR=$GRUPO'/parque_instalado'	
		INSTPROCESADAS=$GRUPO'/inst_procesadas'
		INST_RECIBIDAS=$GRUPO'/inst_recibidas'			
		INST_RECHAZADAS=$GRUPO'/inst_rechazadas'
		
		if [ ! -d "$GRUPO/temporales" ]; then
			mkdir "$GRUPO/temporales"
		fi

		ARCHIVOS=$(ls -1 $INST_RECIBIDAS)
		CANTIDAD=$(echo "$ARCHIVOS" | wc -l)	

		#grabar en el log la cantidad de archivos a procesar
		#loguearU <comando>> <tipo de mensaje>> <mensaje>>
		TIPO='I'
		MENSAJE="inicio de GrabarParqueU la cantidad de archivos a procesar son: $CANTIDAD"
		LoguearU.sh $NOMBRE $TIPO "$MENSAJE"
		if [ $? -ne 0 ]; then
			echo "error al loguear"
		fi
	fi
fi


if [ $AMBIENTE_OK -eq 0 ] && [ ${estaCorriendo} -ne 1 ] ; then
	#tomar un doc para trabajar y grabar en log el archivo a procesar
	echo "GrabarParqueU inicia el proceso de los archivos.."
	for i in ${ARCHIVOS}
	do
		TIPO='I'
		LoguearU.sh $NOMBRE $TIPO "se_inicia_el_proceso_del_archivo:$i"

		#verificar que no este duplicado
		NUEVO_NOMBRE=$INSTPROCESADAS'/'$i'.0'
		if [ ! -f $NUEVO_NOMBRE ] ; then
			#ordenar archivo
			ordenarArchivo $i
			#moverlo a inst_procesadas
			#MoverU $INST_RECIBIDAS'/'$i $INSTPROCESADAS $NOMBRE
			MoverU.sh $INST_RECIBIDAS'/'$i $INSTPROCESADAS'/' $NOMBRE
			#procesar archivo ordenado
			procesarArchivoOrdenado $i
		else
			#echo "el archivo $i esta repetido"
			# MoverU $INST_RECIBIDAS $INST_RECHAZADAS $NOMBRE
			MoverU.sh $INST_RECIBIDAS'/'$i $INST_RECHAZADAS'/' $NOMBRE
			TIPO='A'
			LoguearU.sh $NOMBRE $TIPO "el archivo:"$i" esta repetido"
		fi
	done
	mostrarCantidadRegistrosProcesados
fi
