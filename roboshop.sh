#!/bin/bash
AMI=ami-03265a0778a880afb
SG_ID="sg-08a7ada26617bee9a"
INSTANCE=("mongodb" "redis" "cart" "catalogue" "mysql" "payment" "rabbitmq" "shipping" "user" "web")
ZONE_ID=Z0822260ZMBAKGYDEXJ0
DOMAIN_NAME="techytrees.online"

for i in "${INSTANCE[@]}"
do
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    PRIVATE_IP=(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids   $SG_ID --tag-specifications "resourceType=Instance, Tags= [{Key=Name, Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $PRIVATE_IP"

    #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$PRIVATE_IP'"
            }]
        }
        }]
    }
    '
done