#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILENEW="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILENEW

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "script started executing at: $Y $TIMESTAMP $N"

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
VALIDATE $? "Installing remi"

dnf module enable redis:remi-6.2 -y
VALIDATE $? "Enabling redis"

dnf install redis -y
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g'  /etc/redis/redis.conf
VALIDATE $? "Allowing remote connection"

systemctl enable redis
VALIDATE $? "Enabling redis"

systemctl start redis
VALIDATE $? "Starting redis"