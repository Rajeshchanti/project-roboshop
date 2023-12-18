#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILENEW="/tmp/$0-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "script started executing at: $Y $TIMESTAMP $N" &>> $LOGFILENEW

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
VALIDATE $? "Disable nodejs old version"

dnf module enable nodejs:18 -y &>> $LOGFILENEW
VALIDATE $? "Enable nodejs:18"

dnf install nodejs -y
VALIDATE $? "Installing nodejs"

id roboshop
if [ $? -ne 0 ] #if roboshop user does not exist, then it is failure
then
    useradd roboshop
    VALIDATE $? "creating user"
else
    echo -e "user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILENEW
VALIDATE $? "creating app dir"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILENEW
VALIDATE $? "Downloading code"

unzip -o /tmp/user.zip &>> $LOGFILENEW
VALIDATE $? "unzipping user code"

cd /app
npm install &>> $LOGFILENEW
VALIDATE $? "Installing dependencies"

cp /home/centos/project-roboshop/user.service /etc/systemd/system/user.service
VALIDATE $? "copying user service file"

systemctl daemon-reload &>> $LOGFILENEW
VALIDATE $? "daemon reload"

systemctl enable user 
VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILENEW
VALIDATE $? "starting user"

cp /home/centos/project-roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILENEW
VALIDATE $? "copying mongo file"

dnf install mongodb-org-shell -y &>> $LOGFILENEW
VALIDATE $? "Installing mongoDB client"

mongo --host monogodb.techytrees.online </app/schema/user.js &>> $LOGFILENEW
VALIDATE $? "Loading user data into mongoDB"