SELF="stopD"


daemon=`ps -C 'DetectarU.sh' | grep -c DetectarU.sh`
if [ $daemon = 1 ] ; then
	daemon=`ps -C 'DetectarU.sh' -o pid=`
	kill $daemon
else
	LoguearU.sh $SELF "E" "el demonio no esta ejecutandose\n"
	#echo -e "el demonio no esta ejecutandose\n" #mandar al log
fi


