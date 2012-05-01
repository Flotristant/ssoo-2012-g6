SELF="stopD"

daemon=`ps | grep -c detectar.sh`
if [ `ps | grep -c detectar.sh` = 1 ] ; then
	daemon=`ps | grep detectar.sh | cut -f 2 -d " "`
	kill $daemon
	echo "el demonio ha muerto"
else
	echo "el demonio no esta ejecutandose" #mandar al log
fi


