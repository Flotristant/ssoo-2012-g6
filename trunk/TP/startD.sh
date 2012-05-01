#TOD falta el chequeo de la inicializacion de las variables de ambiente

SELF="startD"

if [ `ps | grep -c detectar.sh` = 0 ] ; then
	detectar.sh &
	echo termine
else
	echo "el demonio ya esta inicializado" # mandar al log...
fi


