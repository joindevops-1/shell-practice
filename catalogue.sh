#!/bin/bash

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

yum install nodejs -y

VALIDATE $? "Installing NodeJS"

useradd roboshop

mkdir /app

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading catalogue artifact"

cd /app 

unzip /tmp/catalogue.zip

npm install 

cp /home/centos/shell-practice/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload

systemctl enable catalogue

systemctl start catalogue

cp /home/centos/shell-practice/mongo.repo /etc/yum.repos.d/mongo.repo

yum install mongodb-org-shell -y


mongo --host mongodb.joindevops.online </app/schema/catalogue.js