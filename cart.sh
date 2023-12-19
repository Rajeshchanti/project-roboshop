#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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
    echo -e "$R Run the command with root user $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

dnf module disable nodejs -y
VALIDATE $? "Disable nodejs"
dnf module enable nodejs:18 -y
VALIDATE $? "Enable nodejs:18"
dnf install nodejs -y
VALIDATE $? "Installing nodejs"
id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating user"
else
    echo -e "Already user is exist...$Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "creating app dir"
curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip
VALIDATE $? "Downloading cart file"
cd /app
unzip -o /tmp/cart.zip
VALIDATE $? "unzipping cart"
npm install
VALIDATE $? "Downloading dependencies"
cp /home/centos/project-roboshop/cart.service /etc/systemd/system/cart.service
VALIDATE $? "copying cart service file"
systemctl daemon-reload
VALIDATE $? "daemon reload"
systemctl enable cart
VALIDATE $? "Enable cart"
systemctl start cart
VALIDATE $? "Start cart"