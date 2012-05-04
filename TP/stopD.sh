SELF="stopD"

daemon=`ps | grep -c detectar.sh`
if [ `ps | grep -c detectar.sh` = 1 ] ; then
	daemon=`ps | grep detectar.sh | cut -f 2 -d " "`
	kill $daemon
else
	echo -e "el demonio no esta ejecutandose\n" #mandar al log
fi


