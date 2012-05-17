Instrucciones de Instalacion TP so 75.08 2012 Copyright (c)

1- Crear en el directorio corriente del usuario un nuevo subdirectorio donde se instalara el programa:
	a) Abrir una terminal,
	b) Pararse en el directorio en el que se va a crear el subdirectorio,
	c) crear un directorio con el comando 'mkdir': mkdir <nombre del directorio>

2- Copiar el archivo "grupo06.tar.gz" al directorio creado en el paso 1, utilizando el comando 'cp':
	a) cp <path completo del archivo "grupo06.tar.gz"> <directorio destino>

3- Crear un directorio con el nombre 'grupo06'

4- Extraer los archivos en el directorio creado en el paso 3 'grupo06':
	a) pararse sobre el directorio creado
	b) ejecutar: tar -xvzf grupo06.tar.gz
*******************************************************************************************************************************************************************
* Atención: NO modifique el nombre de ninguno de los directorios ni archivos.																					  *
*******************************************************************************************************************************************************************
5- Pararse dentro del directorio "grupo06" y darle permiso de ejecución al script "InstalarU.sh" que se encuentra en el mismo utilizando el siguiente comando:
> chmod +x ./InstalarU.sh

6- Si ud. desea instalar todos los comandos del tp al mismo tiempo ejecute el comando:
> ./InstalarU.sh

7- Si en cambio desea instalar los comandos de a uno por vez ejecute en cada paso el comando:
> ./InstalarU.sh <nombre de archivo .sh o .pl>

*******************************************************************************************************************************************************************
* ATENCIÓN: es importante que no ejecute ningún comando hasta que la instalación haya sido completada, es decir, que todos los componentes se encuentren		  * * instalados 																																					  * *******************************************************************************************************************************************************************

8- Una vez terminado el proceso de instalación, nos paramos en el directorio de binarios e iniciamos el ambiente de la siguiente manera
> . ./IniciarU.sh

9- Una vez iniciado el ambiente, el demonio ya estará corriendo preparado para recibir nuevos archivos en el directorio de arribos y proceder con la correcta ejecución del programa.

10- En caso de querer detener la ejecución del demonio, ejecutamos el siguiente comando:
> StopD.sh

11- En caso de querer reanudar la ejecución del demonio, ejecutamos el siguiente comando:
> StartD.sh
