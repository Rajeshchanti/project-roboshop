#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILENEW="/tmp/$0-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "script started executing at:$Y $TIMESTAMP $N" &>> $LOGFILENEW

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

dnf module enable nodejs:18 -y &>> $LOGFILENEW
VALIDATE $? "Enabling nodejs latest version"

dnf install nodejs -y &>> $LOGFILENEW
VALIDATE $? "Installing nodejs"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILENEW
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "Downloading data"

cd /app
VALIDATE $? "Entering to app dir"

unzip -o /tmp/catalogue.zip &>> $LOGFILENEW
VALIDATE $? "Unzipping code"

npm install &>> $LOGFILENEW
VALIDATE $? "Installing dependies"

cp /home/centos/project-roboshop/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload
VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue &>> $LOGFILENEW
VALIDATE $? "Enabling catalogue"

systemctl start catalogue
VALIDATE $? "starting catalogue"

cp /home/centos/project-roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILENEW
VALIDATE $? "copying mongodb file"

dnf install mongodb-org-shell -y &>> $LOGFILENEW
VALIDATE $? "Installing mongoDB Shell"

mongo --host mongodb.techytrees.online </app/schema/catalogue.js &>> $LOGFILENEW
VALIDATE $? "Loading catalogue data into mongoDB"