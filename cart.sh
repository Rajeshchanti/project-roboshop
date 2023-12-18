#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILENEW="/tmp/$0-$TIMESTAMP.log"

R="\e[31m"
Y="\e[32m"
G="\e[33m"
N="\e[0"

echo -e "script started executed at:$Y $TIMESTAMP $N" &>> $LOGFILENEW
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .... $R FAILED $N"
        exit 1
    else
        echo -e "$2 .... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R Run the command with root access $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

dnf module disable nodejs -y &>> $LOGFILENEW
VALIDATE $? "Disable current nodejs version"

dnf module enable nodejs:18 -y &>> $LOGFILENEW
VALIDATE $? "Enable nodejs:18"

dnf install nodejs -y
VALIDATE $? "Installing Nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating user"
else
    echo -e "Already user is existing $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILENEW
VALIDATE $? "creating app dir"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILENEW
VALIDATE $? "Downloading cart code"

unzip /tmp/cart.zip &>> $LOGFILENEW
VALIDATE $? "unzipping cart"

cd /app
npm install &>> $LOGFILENEW
VALIDATE $? "Installing dependencies"

cp /home/centos/project-roboshop/cart.service /etc/systemd/system/cart.service &>> $LOGFILENEW
VALIDATE $? "copying cart service"

systemctl daemon-reload &>> $LOGFILENEW
VALIDATE $? "reloading daemon"

systemctl enable cart
VALIDATE $? "Enable cart"

systemctl start cart &>> $LOGFILENEW
VALIDATE $? "start cart"