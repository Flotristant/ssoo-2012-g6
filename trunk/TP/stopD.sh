SELF="stopD"

if [ `ps | grep -c detectar.sh` = 1 ] ; then
	daemon=`ps | grep detectar.sh | cut -f 2 -d " "`
	kill $daemon
else
	loguearU.sh "$SELF" "E" "demonio no está en ejecución"
fi


