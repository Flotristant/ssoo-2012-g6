#! /bin/bash
#lista=`ls $ARRIDIR`

#PATH_ARRIDIR="$grupo/ARRIDIR"
#PATH_RECHDIR="$grupo/RECHDIR"
PATH_ARRIDIR="./$ARRIDIR"
PATH_RECHDIR="./$RECHDIR/"
PATH_SUCURSALES="Archivos Maestros.csv"
PATH_RECIBIDAS="./inst_recibidas/"

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
			#loguearU.sh "$SELF" "I" "$file: region-sucursal invalida."
			mover.sh "$PATH_ARRIDIR/$file" "$PATH_RECHDIR" "$SELF"
			echo -e "region-sucursal invalida\n"
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
		#loguearU.sh "$SELF" "I" "$file: sucursal valida."
		mover.sh "$PATH_ARRIDIR/$file" "$PATH_RECIBIDAS" "$SELF"     
		echo -e "sucursal valida\n"		
	else
		#loguearU.sh "$SELF" "I" "$file: sucursal no esta vigente."
		mover.sh "$PATH_ARRIDIR/$file" "$PATH_RECHDIR" "$SELF"
		echo -e "sucursal no vigente \n"
	fi

}

#Chequea si el parque no se ejecuta, en ese caso lo ejecuta
function ejecutarGrabarParque
{
	lista=`ls $PATH_RECIBIDAS`                                    
	if [ -n "$lista" -a `ps | grep -c grabarParque.sh` = 0 ] ; then
		#if [ `ps | grep -c grabarParque.sh` = 0 ] ; then
			#grabarParque.sh $lista
			echo -e "grabarParque\n"
			idGrabarParque=`ps | grep grabarParque.sh | cut -f 2 -d " "` 
			echo -e "$idGrabarParque\n"
		#fi
	fi
}

while [ 1 ]
do
	daemon
	sleep $TIME_SLEEP
done

echo -e "termine\n"

