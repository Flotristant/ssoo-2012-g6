SELF="stopD"


daemon=`ps | grep -c DetectarU.sh`
if [ `ps | grep -c DetectarU.sh` = 1 ] ; then
	daemon=`ps -C 'DetectarU.sh' -o pid=`
	kill $daemon
else
	LoguearU.sh $SELF "E" "el demonio no esta ejecutandose\n"
	#echo -e "el demonio no esta ejecutandose\n" #mandar al log
fi


