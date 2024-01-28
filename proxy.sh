#!/bin/bash

queueUrl=$(aws sqs list-queues | jq -r '.QueueUrls[] | select( . | contains("proxy-intents"))')
dedup_id=$(cat /proc/sys/kernel/random/uuid)

aws sqs send-message --queue-url $queueUrl --message-group-id $dedup_id --message-deduplication-id $dedup_id --message-body '{}' | jq >/dev/null

echo "Waiting for proxies to spin up.."
while true 
do
    tasks=$(aws ecs list-tasks --cluster proxy-cluster --family proxy-def | jq -r '.taskArns[]' | tr '\n' ' ')
    if [[ $tasks == *"arn"* ]]
    then
        break 
    fi
    sleep 10
done

eip=$(aws ecs describe-tasks --cluster proxy-cluster --tasks $tasks | jq -r '.tasks[] | .attachments[0].details[] | select( .name == "networkInterfaceId") | .value')
proxies=$(aws ec2 describe-network-interfaces --network-interface-ids $eip | jq -r '.NetworkInterfaces[] | .Association.PublicIp | "root@\(.)"' | grep -v null)

trevorproxy ssh --key ~/.ssh/trevorproxy ${proxies[@]} | grep -v DEBUG

receiptHandle=$(aws sqs receive-message --queue-url $queueUrl | jq -r '.Messages[0].ReceiptHandle')

aws sqs delete-message --queue-url $queueUrl --receipt-handle $receiptHandle
