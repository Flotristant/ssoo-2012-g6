#! /bin/bash

PATH_ARRIDIR="$GRUPO/$ARRIDIR"
PATH_RECHDIR="$GRUPO/$RECHDIR/"
PATH_SUCURSALES="$GRUPO/$MAEDIR/sucu.mae"
PATH_RECIBIDAS="$GRUPO/inst_recibidas/"

SELF="detectar"
TIME_SLEEP=10

# funcion del demonio en si
function daemon
{
	lista=`ls $PATH_ARRIDIR`
	if [ -n "$lista" ] ; then
		valNomArchSucursales $lista
	fi
	
	ejecutarGrabarParque
}

# chequeo del nombre de los archivos en ARRIDIR
function valNomArchSucursales
{
	#$1 lista de archivos en ARRIDIR	
	for file in $@
	do
		region=`echo $file | cut -f 1 -d - `
		sucursal=`echo $file | cut -f 2 -d -`
		sucursalValida=`grep -c "^$region,[^,]\+,$sucursal.*$" "$PATH_SUCURSALES"`
		if [ "$sucursalValida" -eq 1 ] ; then
			chequearVigenciaSucursal $region $sucursal
		else
			loguearU.sh "$SELF" "I" "$file: region-sucursal invalida."
			mover.sh "$PATH_ARRIDIR/$file" "$PATH_RECHDIR" "$SELF"
		fi
	done

}

#Chequeo que la fecha de este día esté dentro de la vigencia de la sucursal
function chequearVigenciaSucursal
{
	region=$1
	sucursal=$2
	
	sucValida=`grep "^$region,[^,]\+,$sucursal.*$" "$PATH_SUCURSALES"`
	startDate=`echo $sucValida | cut -f 7 -d ,| sed 's-\([0-3][0-9]\)/\([0-1][0-9]\)/\([0-9]\{4\}\)-\3\2\1-' `
	endDate=`echo $sucValida | cut -f 8 -d ,| sed 's-\([0-3][0-9]\)/\([0-1][0-9]\)/\([0-9]\{4\}\)-\3\2\1-' `
	dia=`date +"%Y%m%d"`
	antesDelFin=0
	if [ -n "$endDate"  ] ; then
		if [ "$dia" -gt "$endDate"  ] ; then
			antesDelFin=1
		fi
	fi

	if [ "$startDate" -le "$dia" -a "$antesDelFin" = 0 ] ; then
		loguearU.sh "$SELF" "I" "$file: sucursal valida."
		mover.sh "$PATH_ARRIDIR/$file" "$PATH_RECIBIDAS" "$SELF"     
	else
		loguearU.sh "$SELF" "I" "$file: sucursal no esta vigente."
		mover.sh "$PATH_ARRIDIR/$file" "$PATH_RECHDIR" "$SELF"
	fi

}

#Chequea si el parque no se ejecuta, en ese caso lo ejecuta
#GREP: El código de salida es 0 si se selecciona alguna línea, y 1 en caso contrario; si ocurrió algún
#error, y no se indicó -q, el código de salida es 2.

function ejecutarGrabarParque
{
	lista=`ls $PATH_RECIBIDAS`                                    
	if [ -n "$lista" ]; then
		ps -C "GrabarParqueU.sh"|grep --silent 'GrabarParqueU'
		if [ $? -eq 1 ] ; then
			parque=GrabarParqueU.sh &
			idGrabarParque=`ps -C 'GrabarParqueU.sh' -o pid=` 
			echo -e "GrabarParqueU id: $idGrabarParque\n"
		fi
	fi
}

while [ 1 ]
do
	daemon
	sleep $TIME_SLEEP
done

exit(0)
