#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILENEW="/tmp/$0-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "script is started executing at:$Y $TIMESTAMP $N"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ....$R FAILED $N"
        exit 1
    else
        echo -e "$2 ....$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R Run the command with root access $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

dnf install nginx -y
VALIDATE $? "Installing Nginx"

systemctl enable nginx
VALIDATE $? "Enable Nginx"

systemctl start nginx
VALIDATE $? "start Nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing default content"

cd /usr/share/nginx/html
VALIDATE $? "moving to nginx html dir"

unzip -o /tmp/web.zip
VALIDATE $? "unzipping web"

cp /home/centos/project-roboshop/roboshop.conf /etc/nginx/default.d/roboshop.conf
VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx
VALIDATE $? "restarting nginx"