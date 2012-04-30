detectar.sh

if [ `ps | grep -c top` = 0 ] ; then
	echo bien
else
	echo mal
fi


