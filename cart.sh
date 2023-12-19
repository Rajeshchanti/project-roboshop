#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $ID -ne 0 ]
then
    echo -e "$R Run the command with root user $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

