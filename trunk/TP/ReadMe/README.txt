Instrucciones de Instalacion TP so 75.08 2012 Copyright (c)

1- Crear en el directorio corriente del usuario un nuevo subdirectorio donde se instalara el programa.

2- Copiar el archivo "grupo06.tar.gz" al directorio creado en el paso 1.

3- Extraer los archivos en ese mismo directorio.

4- Se creara una carpeta con el nombre "grupo06" con subdirectorios y un archivo .sh. NO modifique el nombre de ninguno de los directorios ni archivos.

5- Darle permiso de ejecución al script "instalarU.sh" que se encuentra en el directorio "grupo06" utilizando el siguiente comando:
> chmod +x ./InstalarU.sh

6- Abrir una terminal y moverse al directorio "grupo06".

7- Si ud. desea instalar todos los comandos del tp al mismo tiempo ejecute el comando:
> ./instalarU.sh

8- Si en cambio desea instalar los comandos de a uno por vez ejecute en cada paso el comando:
> ./instalarU.sh <nombre de archivo .sh o .pl>

9- Una vez terminado el proceso de instalación, nos paramos en el directorio de binarios e iniciamos el ambiente de la siguiente manera
> . ./iniciarU.sh

10- Una vez iniciado el ambiente, el demonio ya estará corriendo preparado para recibir nuevos archivos en el directorio de arribos y proceder con la correcta ejecución del programa.

11- En caso de querer detener la ejecución del demonio, ejecutamos el siguiente comando:
> StopdD.sh

12- En caso de querer reanudar la ejecución del demonio, ejecutamos el siguiente comando:
> StartD.sh
