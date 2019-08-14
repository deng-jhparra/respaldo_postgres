#!/bin/sh
#Descripción: Tarea que hace los respaldos diarios de la bd novosalud
#Autor: Ricardo Alvarado, Jerson Pérez
#Fecha de Desarrollo: 08/06/2017
#Modificado: 20/09/2017

#CONSTANTE
HOST="dbiibsji.c8fbezyp1ptf.us-east-1.rds.amazonaws.com"
BD="portalbsji"
BD_BK="portalbsji"
BD1="bpm"
BD_BK1="bpm"


#VARIABLES DE RESPALDO
FECHA_ACTUAL=`date +%d%m%Y`;
HORA_ACTUAL=`date +%H_%M`;
ARC_RESP="$FECHA_ACTUAL-$HORA_ACTUAL"
MES_ACTUAL=`date +%m`;
YEAR_ACTUAL=`date +%Y`;

#SITIO DONDE SE GUARDARA LOS ARCHIVOS
mkdir -p /backup/Portalbsji/"$YEAR_ACTUAL"
mkdir -p /backup/Portalbsji/"$YEAR_ACTUAL"/"$MES_ACTUAL"
ARCHIVO=/backup/Portalbsji/"$YEAR_ACTUAL"/"$MES_ACTUAL"/"$BD_BK"_$ARC_RESP.sql
ARCHIVO1=/backup/Portalbsji/"$YEAR_ACTUAL"/"$MES_ACTUAL"/"$BD_BK1"_$ARC_RESP.sql

#PASSWORD DEL USUARIO
export PGPASSWORD=pZuaRJ4B

#APLICACION PARA GENERAR EL RESPALDO
/usr/pgsql-9.6/bin/pg_dump -h $HOST -U "backup_user" -w --format plain -v -f "$ARCHIVO" "$BD"
/usr/pgsql-9.6/bin/pg_dump -h $HOST -U "backup_user" -w --format plain -v -f "$ARCHIVO1" "$BD1"

#ACCEDER A LA CARPETA
cd /backup/Portalbsji/"$YEAR_ACTUAL"/"$MES_ACTUAL"/

#CREACION DE ARCHIVO
touch salida.txt 

# CONFIGURACION DE CUERPO DEL CORREO 
echo "El presente correo notifica que se ha realizado el respaldo de la base de datos del ambiente de producción de la nueva Banca en Línea BSJI ">> /opt/tareaprogramada/correo/correo.txt
echo " " >> /opt/tareaprogramada/correo/correo.txt
echo "Estatus de respaldo de base de datos en AWS Producción" >> /opt/tareaprogramada/correo/correo.txt
echo " " >> /opt/tareaprogramada/correo/correo.txt


##      BD_BK
echo "Servidor: AWS  Base de datos: $BD  Fecha: $FECHA_ACTUAL  Hora: $HORA_ACTUAL" >> /opt/tareaprogramada/correo/correo.txt
echo " " >> /opt/tareaprogramada/correo/correo.txt
echo "Tamaño del archivo .sql" >> /opt/tareaprogramada/correo/correo.txt
echo " " >> /opt/tareaprogramada/correo/correo.txt
du -sch "$BD_BK"_$ARC_RESP.sql >> /opt/tareaprogramada/correo/correo.txt
#COMPRIMIR ARCHIVO BACKUP
7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m "$HOST_$BD_BK"_$ARC_RESP.7z "$HOST_$BD_BK"_$ARC_RESP.sql
echo " " >> /opt/tareaprogramada/correo/correo.txt
echo "Tamaño del archivo comprimido" >> /opt/tareaprogramada/correo/correo.txt
echo " " >> /opt/tareaprogramada/correo/correo.txt
du -sch "$BD_BK"_$ARC_RESP.7z >> /opt/tareaprogramada/correo/correo.txt
echo " " >> /opt/tareaprogramada/correo/correo.txt

##	BD_BK1
echo "Servidor: AWS  Base de datos: $BD1  Fecha: $FECHA_ACTUAL  Hora: $HORA_ACTUAL" >> /opt/tareaprogramada/correo/correo.txt
echo " " >> /opt/tareaprogramada/correo/correo.txt
echo "Tamaño del archivo .sql" >> /opt/tareaprogramada/correo/correo.txt
echo " " >> /opt/tareaprogramada/correo/correo.txt
du -sch "$BD_BK1"_$ARC_RESP.sql >> /opt/tareaprogramada/correo/correo.txt
#COMPRIMIR ARCHIVO BACKUP
7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m "$HOST_$BD_BK1"_$ARC_RESP.7z "$HOST_$BD_BK1"_$ARC_RESP.sql
echo " " >> /opt/tareaprogramada/correo/correo.txt
echo "Tamaño del archivo comprimido" >> /opt/tareaprogramada/correo/correo.txt
echo " " >> /opt/tareaprogramada/correo/correo.txt
du -sch "$BD_BK1"_$ARC_RESP.7z >> /opt/tareaprogramada/correo/correo.txt
echo " " >> /opt/tareaprogramada/correo/correo.txt


#CALCULO DEL ARCHIVO EN SQL
du -sch "$BD_BK"_$ARC_RESP.sql >> salida.txt
du -sch "$BD_BK1"_$ARC_RESP.sql >> salida.txt

#BORRAR ARCHIVO CON EXTENSION .SQL
rm  "$BD_BK"_$ARC_RESP.sql
rm  "$BD_BK1"_$ARC_RESP.sql

#CALCULO DEL ARCHIVO EN 7ZIP 
du -sch "$HOST_$BD_BK"_$ARC_RESP.7z >> salida.txt
du -sch "$HOST_$BD_BK1"_$ARC_RESP.7z >> salida.txt

#ENVIO DE CORREO INDICANDO EL ESTATUS DEL RESPALDO
sh /opt/tareaprogramada/correo/enviar_correo.sh
