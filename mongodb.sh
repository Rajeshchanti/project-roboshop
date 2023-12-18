#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILENEW="/tmp/$0-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "script is started executed at: $Y $TIMESTAMP $N" &>> $LOGFILENEW

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILENEW
VALIDATE $? "copying mongo.repo file"

dnf install mongodb-org -y &>> $LOGFILENEW
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>> $LOGFILENEW
VALIDATE $? "enabling MongoDB"

systemctl start mongod &>> $LOGFILENEW
VALIDATE $? "starting mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
systemctl restart mongod &>> $LOGFILENEW
VALIDATE $? "restarting mongoDB"

