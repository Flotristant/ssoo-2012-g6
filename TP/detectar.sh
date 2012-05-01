#! /bin/bash
#lista=`ls $ARRIDIR`

PATH_ARRIDIR="$grupo/ARRIDIR"
PATH_RECHDIR="$grupo/RECHDIR"
PATH_SUCURSALES="$grupo/"

SELF="detectar"

# funcion del demonio en si
function daemon
{
	lista=`ls $PATH_ARRIDIR`
	if [ "$lista" != "" ] ; then
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

		regionValida=`grep -c "^$region,[^,]\+,$sucursal[,[^,]\+]\{5\}$" $PATH_REGIONES`

		if [ $regionValida = 1 ] ; then
			chequearVigenciaSucursal $region $sucursal
		else
			# falta el log para poder llamarlo... con "$SELF" "I" "$file: region-sucursal inexistente.\n"
			mover.sh "$PATH_REGIONES/$file" "$PATH_RECHDIR" "$SELF"
		fi
	done

}

#Chequeo que la fecha de este día esté dentro de la vigencia de la sucursal
function chequearVigenciaSucursal
{
	region=$1
	sucursal=$2
	
	sucValida=`grep "^$region,[^,]\+,$sucursal[,[^,]\+]\{5\}$" $PATH_REGIONES`
	startDate=`echo $sucValida | cut -f 7 -d ,| sed 's-\([0-3][0-9]\)/\([0-1][0-9]\)/\([0-9]\{4\}\)-\3\2\1' `
	endDate=`echo $sucValida | cut -f 8 -d ,| sed 's-\([0-3][0-9]\)/\([0-1][0-9]\)/\([0-9]\{4\}\)-\3\2\1' `
	dia=`date +"20%y%m%d"`
	antesDelFin=0
	if [ -n $endDate  ] ; then
		if [ $dia -gt $endDate  ] ; then
			antesDelFin=1
		fi
	fi

	if [ [ $startDate -le $dia] -a [ $antesDelFin = 0 ] ] ; then
		# falta el log para poder llamarlo... con "$SELF" "I" "$file: sucursal valida.\n"
		mover.sh "$PATH_REGIONES/$file" "$PATH_RECIBIDAS" "$SELF"                                    # cuidado con el path del lugar recibido
	else
		# falta el log para poder llamarlo... con "$SELF" "I" "$file: sucursal no esta vigente.\n"
		mover.sh "$PATH_REGIONES/$file" "$PATH_RECHDIR" "$SELF"
	fi

}

#Chequea si el parque no se ejecuta, en ese caso lo ejecuta
function ejecutarGrabarParque
{
	lista=`ls $PATH_RECIBIDAS`                                    # cuidado con el path del lugar recibido
	if [ "$lista" != "" ] ; then
		if [ `ps | grep -c grabarParque.sh` = 0 ]
			grabarParque.sh $lista
			idGrabarParque=`ps | grep grabarParque.sh | cut -f 2 -d " "` 
		fi
	fi
}

while [ 1 ]
do
	daemon
	sleep 30
done

echo termine

