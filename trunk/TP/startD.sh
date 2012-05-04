#TOD falta el chequeo de la inicializacion de las variables de ambiente

SELF="startD"

if [ `ps | grep -c detectar.sh` = 0 ] ; then
	if [ -n "$ARRIDIR" -a -n "$RECHDIR" ] ; then
		detectar.sh &
	else
		#loguearU.sh "$SELF" "SE" "$ARRIDIR variables de ambiente no inicializadas"
		echo -e "no esta inicializado el ambiente\n"
	fi
else
	#loguearU.sh "$SELF" "E" "demonio ya inicializado"
	echo -e "el demonio ya esta inicializado\n"
fi


