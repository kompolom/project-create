#!/bin/bash

########################
# Defuaults            #
########################
PROJECTNAME=$1
ROOTDIR=$HOME/projects

##
IP='127.0.1.1'
PORT=80
DOMAIN='desktop.lan'
WEBSERVER_ROOT=$ROOTDIR 
WEBSERVER_CONFIG_DIR='/etc/apache2'
WEBSERVER_ACCESS_GROUP='www-data'
WEBSERVER_PROJECT_DIR=$WEBSERVER_ROOT/$PROJECTNAME/$PROJECTNAME
FULL_DOMAIN_NAME=$PROJECTNAME.$DOMAIN 
VHOST_FILE=$WEBSERVER_CONFIG_DIR/sites-available/$FULL_DOMAIN_NAME.conf

DNS_FILE='/etc/hosts'


echo "Создаю директорию $ROOTDIR/$PROJECTNAME"
mkdir -pv $ROOTDIR/$PROJECTNAME
cd $ROOTDIR/$PROJECTNAME
mkdir -pv src
mkdir -pv $ROOTDIR/$PROJECTNAME/$PROJECTNAME
cd $ROOTDIR/$PROJECTNAME/$PROJECTNAME
git init

#Create VirtualHost
function echo_vhost_content(){ 
        echo "<VirtualHost *:$PORT>" >> $VHOST_FILE
        echo "  ServerName $FULL_DOMAIN_NAME" >> $VHOST_FILE
        echo "  DocumentRoot $WEBSERVER_PROJECT_DIR" >> $VHOST_FILE
        echo "  <Directory $WEBSERVER_PROJECT_DIR>" >> $VHOST_FILE
        echo "    Options Indexes FollowSymLinks" >> $VHOST_FILE 
        echo "    AllowOverride All" >> $VHOST_FILE 
        echo "    Require all granted" >> $VHOST_FILE 
        echo "  </Directory>" >> $VHOST_FILE
        echo "</VirtualHost>" >> $VHOST_FILE
}
function check_file(){
FILE=$1
if ! [ -f $FILE ]; then
        echo "Файл $FILE не существует"
        exit 2
fi
}
function check_file_exists(){
        FILE=$1
        if [ -f $FILE ];then
                echo -n "Файл $FILE существует. Перезаписать? (y/n)"
                read item
                case "$item" in 
                        y|Y) rm $FILE
                                ;;
                        n|N) echo "Выходим"
                                exit 0

                esac
        fi
}


#Существует ли файл?
check_file_exists $VHOST_FILE

#Если все ОК создаем
touch $VHOST_FILE
check_file $VHOST_FILE
echo "Creating VirtualHost for $FULL_DOMAIN_NAME"
echo_vhost_content
chmod 664 $VHOST_FILE
sudo chown $USER:$WEBSERVER_ACCESS_GROUP $VHOST_FILE

#ENABILING SITE
cd $WEBSERVER_CONFIG_DIR/sites-available/
echo "Включаю VirtualHost (`pwd`) $VHOST_FILE"
sudo a2ensite `basename $VHOST_FILE`
sudo service apache2 reload

#CREATE RECORD INTO HOSTS
echo "Создаю запись в $DNS_FILE"
str="$IP   $FULL_DOMAIN_NAME #CREATED FOR $PROJECTNAME"
sudo echo $str >> $DNS_FILE
exit 0
