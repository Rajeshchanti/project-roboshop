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

dnf install python36 gcc python3-devel -y
VALIDATE $? "Installing py"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating user"
else
    echo -e "Already user exist...$Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILENEW
VALIDATE $? "creating app dir"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILENEW
VALIDATE $? "Downloading payment zip file"

cd /app
unzip -o /tmp/payment.zip &>> $LOGFILENEW
VALIDATE $? "unzipping payment"

cd /app
pip3.6 install -r requirements.txt &>> $LOGFILENEW
VALIDATE $? "Installing dependencies"

cp /home/centos/project-roboshop/payment.service /etc/systemd/system/payment.service &>> $LOGFILENEW
VALIDATE $? "copying payment service file"

systemctl daemon-reload
VALIDATE $? "Reloading daemon"

systemctl enable payment &>> $LOGFILENEW
VALIDATE $? "Enable payment"

systemctl start payment &>> $LOGFILENEW
VALIDATE $? "start payment"