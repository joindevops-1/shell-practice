#!/bin/bash


DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE
 
VALIDATE $? "setting npm source"

yum install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NodeJS"

useradd roboshop &>> $LOGFILE

mkdir /app

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading cart artifact"

cd /app 

unzip /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "unzipped cart artifact"

npm install &>> $LOGFILE

VALIDATE $? "Installed app dependencies"

cp /home/centos/shell-practice/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "copied cart service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "system daemon reloaded"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "Enabled cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "Started cart"