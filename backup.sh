#!/bin/sh

BACKUP_DIR=/var/backups_of_users
BACKUP_LIST=ruben
BACKUP_MAXCOUNT=1
BACKUP_LOG=YES

# GENERACIÓN DE LOGS ------------------------------------------------------------

if [ $BACKUP_LOG = YES ]; then
	LOG_FILE="$HOME/temp_log"
	exec >> "$LOG_FILE"
	exec 2>&1
fi

# GENERACIÓN DE LOGS ------------------------------------------------------------

# COMPROBACIÓN DE ERRORES -------------------------------------------------------

if [ ! -e $BACKUP_DIR ]; then

	echo "Creating backups directory in $BACKUP_DIR"
	mkdir -p -m 775 $BACKUP_DIR

fi

# COMPROBACIÓN DE ERRORES -------------------------------------------------------

# CREACION DE LISTA CON LOS DIRECTORIOS SELECCIONADOS ---------------------------

BACKUP_LIST_DIRS_AUX=`cat /etc/passwd | cut -f1,6 -d:`

for line in $BACKUP_LIST_DIRS_AUX; do
	
	if [ $BACKUP_MAXCOUNT -le 0 ]; then
		break
	fi

	user_name=`echo $line | cut -f1 -d:`

	if [ ! -z `echo $BACKUP_LIST | grep $user_name` ]; then 
		BACKUP_LIST_DIRS="$BACKUP_LIST_DIRS $line"
		BACKUP_MAXCOUNT=`expr $BACKUP_MAXCOUNT - 1`
	fi

done

for line in $BACKUP_LIST_DIRS_AUX; do
	
	if [ $BACKUP_MAXCOUNT -le 0 ]; then
		break
	fi

	user_home=`echo $line | cut -f2 -d:`
	backup_file_yes="$user_home/.backup_SI"

	if [ -e $backup_file_yes -a -z `echo $BACKUP_LIST_DIRS | grep $user_name` ]; then 
		BACKUP_LIST_DIRS="$BACKUP_LIST_DIRS $line"
		BACKUP_MAXCOUNT=`expr $BACKUP_MAXCOUNT - 1`
	fi

done

# CREACION DE LISTA CON LOS DIRECTORIOS SELECCIONADOS ---------------------------

# CREACION DE LAS COPIAS DE SEGURIDAD -------------------------------------------

for line in $BACKUP_LIST_DIRS; do
	
	user_name=`echo $line | cut -f1 -d:`
	user_home=`echo $line | cut -f2 -d:`
	user_home=/home/ruben/FIC/ASO/HOLA

	date=`date "+%Y-%m-%d-%k-%M"`
	tar_name=$user_name-$date.tar.gz
	( cd $BACKUP_DIR && tar -zcf $tar_name $user_home 2> /dev/null && chown $user_name $tar_name && chmod 700 $tar_name)

	if [ -e "$BACKUP_DIR/$tar_name" ]; then 
		echo "Backup for $user_name of $user_home created in $BACKUP_DIR/$tar_name"
	else
		echo "Could not make backup for $user_name of $user_home created in $BACKUP_DIR/$tar_name"
	fi
	

done

# CREACION DE LAS COPIAS DE SEGURIDAD -------------------------------------------

# GENERACIÓN DE LOGS ------------------------------------------------------------

if [ $BACKUP_LOG = YES ]; then
	logger -f $LOG_FILE -p user.notice -t 'backup_script'
	rm $LOG_FILE
fi

# GENERACIÓN DE LOGS ------------------------------------------------------------

exit 0