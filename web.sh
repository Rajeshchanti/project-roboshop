#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILENEW="/tmp/$0-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "script is started executing at:$Y $TIMESTAMP $N" &>> $LOGFILENEW

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

dnf install nginx -y &>> $LOGFILENEW
VALIDATE $? "Installing Nginx"

systemctl enable nginx
VALIDATE $? "Enable Nginx"

systemctl start nginx &>> $LOGFILENEW
VALIDATE $? "start Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILENEW
VALIDATE $? "removing default content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILENEW
VALIDATE $? "Downloading web file"

cd /usr/share/nginx/html &>> $LOGFILENEW
VALIDATE $? "moving to nginx html dir"

unzip -o /tmp/web.zip &>> $LOGFILENEW
VALIDATE $? "unzipping web"

cp /home/centos/project-roboshop/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILENEW
VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx &>> $LOGFILENEW
VALIDATE $? "restarting nginx"