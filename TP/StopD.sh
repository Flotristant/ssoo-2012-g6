SELF="StopD"

if [ `ps | grep -c DetectarU.sh` = 1 ] ; then
	daemon=`ps | grep DetectarU.sh | cut -f 2 -d " "`
	kill $daemon
else
	loguearU.sh "$SELF" "E" "demonio no está en ejecución"
fi


