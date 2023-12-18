#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILENEW="/tmp/$0-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "script started executing at:$Y $TIMESTAMP $N"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .....$R FAILED $N"
        exit 1
    else
        echo -e "$2 .....$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R Run the command with root access $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

dnf module disable nodejs -y
VALIDATE $? "Disabling nodejs old version"

dnf module enable nodejs:18 -y
VALIDATE $? "Enabling nodejs latest version"

dnf install nodejs -y
VALIDATE $? "Installing nodejs"

useradd roboshop
VALIDATE $? "Adding user"

mkdir /app
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "Downloading data"

cd /app
VALIDATE $? "Entering to app dir"

unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping code"

npm install
VALIDATE $? "Installing dependies"

cp /home/centos/project-roboshop/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload
VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue
VALIDATE $? "Enabling catalogue"

systemctl start catalogue
VALIDATE $? "starting catalogue"

cp /home/centos/project-roboshop/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb file"

dnf install mongodb-org-shell -y
VALIDATE $? "Installing mongoDB Shell"

mongo --host monogodb.techytrees.online </app/schema/catalogue.js
VALIDATE $? "Loading catalogue data into mongoDB"