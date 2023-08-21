#!/bin/bash

# we need to create 11 EC2 Instances. mongodb, mysql are t3.medium
# we need to create route 53 records
NAMES=("mongodb" "mysql" "redis" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
HOSTED_ZONE_ID=Z100752334QE9LTNXCY6Z
DOMAIN_NAME=joindevops.online
INSTANCE_TYPE="t2.micro"
for i in "${NAMES[@]}"
do
    echo "Creating $i EC2 instance"

    if [[ $i == "mongodb" || $i == "mysql" ]];
    then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    if [ $i == "web" ];
    then
        PRIAVATE_IP=$(aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE --security-group-ids sg-0b34d8689bd628e3f --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"| jq -r '.Instances[0].PublicIpAddress')
    else
        PRIAVATE_IP=$(aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE --security-group-ids sg-06b9f1182c28b0309 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"| jq -r '.Instances[0].PrivateIpAddress')
    fi

    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '{
    "Changes": [
        {
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "'$i.$DOMAIN_NAME'",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [
                    {
                        "Value": "'$PRIAVATE_IP'"
                    }
                ]
            }
        }
    ]
    }'
done