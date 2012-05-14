SELF="StartD"

if [ `ps | grep -c DetectarU.sh` = 0 ] ; then
	if [ -n "$ARRIDIR" -a -n "$RECHDIR" ] ; then
		DetectarU.sh &
	else
		LoguearU.sh "$SELF" "SE" "variables de ambiente no inicializadas"
	fi
else
	LoguearU.sh "$SELF" "E" "demonio ya inicializado"
fi


