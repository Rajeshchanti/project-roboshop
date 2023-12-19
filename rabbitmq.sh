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
        echo -e "$2 .... $R FAILED $N"
        exit 1
    else
        echo -e "$2 .... $G SUCCESS $N"
    fi
}

if [ $? -ne 0 ]
then
    echo -e "$R Run the command with root access $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILENEW
VALIDATE $? "Dowloading erlang"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILENEW
VALIDATE $? "Downloading rabbitmq"

dnf install rabbitmq-server -y &>> $LOGFILENEW
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOGFILENEW
VALIDATE $? "Enable rabbitmq-server"

systemctl start rabbitmq-server &>> $LOGFILENEW
VALIDATE $? "Start rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILENEW
VALIDATE $? "creating user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILENEW
VALIDATE $? "setting permissions"