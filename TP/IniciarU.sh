
#####CODIGOS DE ERROR#####
errorInstalacion=10
errorInicializacion=11
errorMaestros=12


function demonioCorriendo
{
	#numProceso=`ps -ef | grep [d]etectarU | awk '{ print $2 }'`
	numProceso=`pgrep DetectarU.sh`
	if [ -z $numProceso ]; then
		numProceso=0
	fi
	echo $numProceso
}

function mostrarArchivos	
{
	#Recibe un path
	#Devuelve los archivos dentro del path
	lista=`ls -1 $1`
	archivosBin="PATH = "`echo $1`"\nArchivos: "$lista"\n\n"
	echo $archivosBin
	
}

function mostrarVariables
{
	echo "GRUPO: $GRUPO"	
	echo "BINDIR: $BINDIR"
    	echo "ARRIDIR: $ARRIDIR"
	echo "RECHDIR: $RECHDIR"
	echo "MAEDIR: $MAEDIR"
	echo "LOGDIR: $LOGDIR"
	echo "REPODIR: $REPODIR"
	echo "CONFDIR: $CONFDIR"
	echo "LOGEXT: $LOGEXT"
	echo "LOGSIZE: $LOGSIZE"
	echo "DATASIZE: $DATASIZE"
}


function obtenerVariablesAmbiente
{

	GRUPO=`grep "GRUPO" "$1" | cut -d"=" -f 2`
	ARRIDIR=`grep "ARRIDIR" "$1" | cut -d"=" -f 2`
	RECHDIR=`grep "RECHDIR" "$1" | cut -d"=" -f 2`
	BINDIR=`grep "BINDIR" "$1" | cut -d"=" -f 2`
	MAEDIR=`grep "MAEDIR" "$1" | cut -d"=" -f 2`
	REPODIR=`grep "REPODIR" "$1" | cut -d"=" -f 2`
	LOGDIR=`grep "LOGDIR" "$1" | cut -d"=" -f 2`
	LOGEXT=`grep "LOGEXT" "$1" | cut -d"=" -f 2`
	LOGSIZE=`grep "LOGSIZE" "$1" | cut -d"=" -f 2`
	DATASIZE=`grep "DATASIZE" "$1" | cut -d"=" -f 2`
	CONFDIR="$GRUPO/confdir"

}

function CrearMsjsSalida
{
	
	msjConfdir="Libreria del sistema:  $1\n"
	msjBindir="Directorio de instalacion de los ejecutables: $2 \n"
	msjArridir="Directorio de arribo de los archivos externos: $3 \n\n"
	msjRechdir="Directorio de grabación de los archivos externos rechazados: $4 \n\n"
	msjMaedir="Directorio de instalación de los archivos maestros: $5 \n"
	msjLogdir="Directorio de grabación de los logs de auditoria: $6 \n\n"
	msjRepodir="Directorio de grabación de los reportes de salida: $7 \n\n"
	msjFinal="Estado del sistema: "
}

function validarExistenciaArch
{
	if [ -f $1 ]; then
		 existe=1
	else
		 existe=0	
	fi
	echo $existe
}

function validarExistenciaDirectorios
{
	#                      2       3      4        5     6      7        8		9
	#Chequea que exista: BINDIR,ARRIDIR,RECHDIR,MAEDIR,LOGDIR,REPODIR,CONFDIR,GRUPO
	archivoConf=`basename $1`
	CrearMsjsSalida $archivoConf $2 $3 $4 $5 $6 $7

	GRUPO=$9
	bin=0
	arri=0
	rech=0
	mae=0
	log=0
	repo=0
	conf=0
	rutaTP="$GRUPO/"	
	msjEstadoDelSistema="INICIALIZADO"
	

	#CONFDIR
	#listaConf=$(mostrarArchivos `echo $PWD | sed "s-$BINDIR-$CONFDIR-"`)
	listaConf=$(mostrarArchivos "$GRUPO/confdir")
	if [ -d $rutaTP"confdir" ]; then
		msjExistentes=$msjExistentes$msjConfdir$listaConf
		msjComponentesExistentes="Componentes Existentes: \n"
	else
		msj=$msj$msjConfdir$listaConf
		msjCompFaltantes="Componentes Faltantes: \n"
		msjEstadoDelSistema="PENDIENTE DE INSTALACION"
		conf=1
	fi
	#ARRIDIR
	if [ -d $rutaTP$3 ]; then
		msjExistentes=$msjExistentes$msjArridir
		msjComponentesExistentes="Componentes Existentes: \n\n"
	else 
		msj=$msj$msjArridir
		msjCompFaltantes="Componentes Faltantes: \n\n"
		msjEstadoDelSistema="PENDIENTE DE INSTALACION"
		arri=1
	fi
	#RECHDIR
	if [ -d $rutaTP$4 ]; then
		msjExistentes=$msjExistentes$msjRechdir
		msjComponentesExistentes="Componentes Existentes: \n\n"
	else
		msj=$msj$msjRechdir
		msjCompFaltantes="Componentes Faltantes: \n\n"
		msjEstadoDelSistema="PENDIENTE DE INSTALACION"
		rech=1
	fi
	#BINDIR
	listaComandos=$(mostrarArchivos "$GRUPO/$BINDIR") 
	if [ -d $rutaTP$2 ]; then
		msjExistentes=$msjExistentes$msjBindir$listaComandos 
		msjComponentesExistentes="Componentes Existentes: \n"
	else		
		msj=$msj$msjBindir$listaComandos
		msjCompFaltantes="Componentes Faltantes: \n"
		msjEstadoDelSistema="PENDIENTE DE INSTALACION"
		bin=1
	fi
	#MAEDIR
	listaMaestros=$(mostrarArchivos "$GRUPO/$MAEDIR")
	if [ -d $rutaTP$5 ]; then
		msjExistentes=$msjExistentes$msjMaedir$listaMaestros
		msjComponentesExistentes="Componentes Existentes: \n\n"

	else
		msj=$msj$msjMaedir$listaMaestros
		msjCompFaltantes="Componentes Faltantes: \n\n"
		msjEstadoDelSistema="PENDIENTE DE INSTALACION"
		mae=1
	fi
	#LOGDIR
	if [ -d $rutaTP$6 ]; then
		msjExistentes=$msjExistentes$msjLogdir
		msjComponentesExistentes="Componentes Existentes: \n\n"
	else
		msj=$msj$msjLogdir
		msjCompFaltantes="Componentes Faltantes: \n\n"
		msjEstadoDelSistema="PENDIENTE DE INSTALACION"
		log=1
	fi
	#REPODIR
	if [ -d $rutaTP$7 ]; then
		msjExistentes=$msjExistentes$msjRepodir
		msjComponentesExistentes="Componentes Existentes: \n\n"
	else
		msj=$msj$msjRepodir
		msjCompFaltantes="Componentes Faltantes: \n\n"
		msjEstadoDelSistema="PENDIENTE DE INSTALACION"
		repo=1
	fi

	resultado=`expr $bin + $arri + $rech + $mae + $log + $repo + $conf`
	msjEstadoInstalacion=$msjComponentesExistentes$msjExistentes$msjCompFaltantes$msj$msjFinal$msjEstadoDelSistema
}


function validarPermisos
{ 
	if [ ! -$1 "$2" ]
	then 
    		echo 1
	else 
		echo 0 
	fi 
}


################################################################################
################################################################################
#Leo del archivo de conf las variables de los directorios#######################
#Inicializo el ambiente#########################################################
################################################################################
PID=$(demonioCorriendo)
#si el demonio esta corriendo no puedo llamar a iniciarlizar nuevamente
if [ ! -z $BINDIR ]; then
	echo "Ambiente ya inicializado"
	mostrarVariables
else

	rutaConf=../confdir/instalarU.conf
	archConf=$(validarExistenciaArch $rutaConf)


	
	if [ $archConf -eq 0 ]; then
		echo -e "No se encuentra el archivo de configuración"
		INSTALADO=0
	else
		INSTALADO=1
	fi
	
	if [ ! $INSTALADO -eq 0 ]; then
		chmod 777 LoguearU.sh	

		obtenerVariablesAmbiente $rutaConf
		export BINDIR
		export ARRIDIR
		export RECHDIR
		export MAEDIR
		export GRUPO
		export LOGDIR
		export REPODIR
		export LOGEXT
		export LOGSIZE
		export DATASIZE

		./LoguearU.sh "IniciarU" "I" "Inicio de ejecución"

		validarExistenciaDirectorios $rutaConf $BINDIR $ARRIDIR $RECHDIR $MAEDIR $LOGDIR $REPODIR $CONFDIR $GRUPO
		#Informo el estado de los directorios y las variables
		echo -e $msjEstadoInstalacion

		if [ $resultado -eq 0 ] ; then
			errorIni=0
		else
			./LoguearU.sh "IniciarU" "SE" "Hay componentes pendiente de instalación"
			errorIni=1
		fi

		

		################################################################################
		#Permisos#######################################################################
		################################################################################
		#ASUMO QUE EN EL ARCH DE CONFIGURACION ESTA EL NOMBRE DEL DIR Y NO EL PATH
		pathMaestros=`echo $PWD | sed "s/$BINDIR/$MAEDIR/"`
		productos=$pathMaestros"/prod.mae"
		sucursales=$pathMaestros"/sucu.mae"
		clientes=$pathMaestros"/cli.mae"

		error=0
		permisoProd=$(validarPermisos "r" $productos)
		if [ $permisoProd -eq 1 ]; then
			#loguear
			#echo "IniciarU SE 'El archivo `basename $productos` no existe, o no tiene permisos de lectura'"
			./LoguearU.sh "IniciarU" "SE" "El archivo `basename $productos` no existe, o no tiene permisos de lectura" 
			error=1
		fi
		permisoSuc=$(validarPermisos "r" $sucursales)
		if [ $permisoSuc -eq 1 ]; then
			#loguear
			#echo "IniciarU SE El archivo `basename $sucursales` no existe, o no tiene permisos de lectura"
			./LoguearU.sh "IniciarU" "SE" "El archivo `basename $sucursales` no existe, o no tiene permisos de lectura" 
			error=1
		fi
		permisoCli=$(validarPermisos "r" $clientes)
		if [ $permisoCli -eq 1 ]; then
			#loguear
			#echo "IniciarU SE El archivo `basename $clientes` no existe, o no tiene permisos de lectura"
			./LoguearU.sh "IniciarU" "SE" "El archivo `basename $clientes` no existe, o no tiene permisos de lectura" 
			error=1
		fi


		#Si hay error de inicializacion arrojo error
		if [ $errorIni -eq 1 ] ; then
			return $errorInicializacion
		fi
		#Si hay error de permisos o no existe algun maestro arroja error
		if [ $error -eq 1 ]; then
			return $errorMaestros
		fi
		
		INICIALIZADO=1
		export INICIALIZADO

		#Si estoy aca es porque se inicializo correctamente entonces muestro las variables
		################################################################################
		#DetectarU######################################################################
		################################################################################
		echo "Las Variables de Ambiente son:"
		mostrarVariables

		#Se le otorga permiso de ejecución a los scripts
		chmod 777 DetectarU.sh
		chmod 777 MirarU.sh
		chmod 777 ListarU.pl
		chmod 777 GrabarParqueU.sh
		chmod 777 MoverU.sh
		chmod 777 StartD.sh
		chmod 777 StopD.sh

		#PATH
		PATH=$PATH:$PWD
		export PATH

		#LANZO EL DEMONIO
		PID=$(demonioCorriendo)
		if [ $PID -eq 0 ]; then
			StartD.sh
			PID=$(demonioCorriendo)
		fi

		#loguear

		#echo "IniciarU 'Demonio corriendo bajo el Nro: $PID'"	
		LoguearU.sh "IniciarU" "I" "Demonio corriendo bajo el Nro: $PID"
		echo "Demonio corriendo bajo el Nro $PID"
	fi
fi	









