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

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading user artifact"

cd /app 

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipped user artifact"

npm install &>> $LOGFILE

VALIDATE $? "Installed app dependencies"

cp /home/centos/shell-practice/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "copied user service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "system daemon reloaded"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enabled user"

systemctl start user &>> $LOGFILE

VALIDATE $? "Started user"

cp /home/centos/shell-practice/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied mongo repo"

yum install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installed mongo client"


mongo --host mongodb.joindevops.online </app/schema/user.js &>> $LOGFILE

VALIDATE $? "loaded category data"