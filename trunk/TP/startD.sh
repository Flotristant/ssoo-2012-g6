SELF="startD"

if [ `ps | grep -c detectar.sh` = 0 ] ; then
	if [ -n "$ARRIDIR" -a -n "$RECHDIR" ] ; then
		detectar.sh &
	else
		loguearU.sh "$SELF" "SE" "variables de ambiente no inicializadas"
	fi
else
	loguearU.sh "$SELF" "E" "demonio ya inicializado"
fi


