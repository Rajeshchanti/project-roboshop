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

dnf install maven -y &>> $LOGFILENEW
VALIDATE $? "Installing maven"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating user"
else
    echo -e "Already user is exist....$Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILENEW
VALIDATE $? "creating app dir"

curl -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILENEW
VALIDATE $? "Downloading shipping file"

cd /app
VALIDATE $? "moving to app dir"

unzip -o /tmp/shipping.zip &>> $LOGFILENEW
VALIDATE $? "unzipping shipping file"

mvn clean package &>> $LOGFILENEW
VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILENEW
VALIDATE $? "Renaming jar file"

cp /home/centos/project-roboshop/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILENEW
VALIDATE $? "copying shipping file"

systemctl daemon-reload
VALIDATE $? "daemon reload"

systemctl enable shipping
VALIDATE $? "Enable shipping"

systemctl start shipping &>> $LOGFILENEW
VALIDATE $? "start shipping"

dnf install mysql -y &>> $LOGFILENEW
VALIDATE $? "Installing mysql"

mysql -h mysql.techytrees.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILENEW
VALIDATE $? "loading shipping data"

systemctl restart shipping &>> $LOGFILENEW
VALIDATE $? "restart shipping"