#!/bin/bash
CLIENT_NAME=`hostid`
NUMBER_CLUSTERS=1

for i in {1..1}
do
    export NAME="$CLIENT_NAME-$i.jb.io"
    echo "the name is $NAME"
    export KOPS_STATE_STORE="s3://jb-cloud-terraform-vpc-remote-state"
    export ZONES="eu-west-1a"
    export NETWORK_CIDR=10.60.0.0/16
    cd $CLIENT_NAME/clusters/cluster-$i/ 
    #terraform destroy -force
    kops delete cluster --name=$CLIENT_NAME-$i.jb.io --yes
    echo "Dir on exit"
    cd ../../../
    pwd

echo "Printing all Master IP's for cluster $CLIENT_NAME-$i.jb.io"
aws ec2 describe-instances --region=eu-west-1 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --filters "Name=tag:k8s.io/role/master,Values=1" "Name=tag:KubernetesCluster,Values=$CLIENT_NAME-$i.jb.io" "Name=instance-state-code,Values=16" --output text | sort -k2f
echo "################################"

echo "Printing all nodes IP's for cluster $CLIENT_NAME-$i.jb.io"
aws ec2 describe-instances --region=eu-west-1 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --filters "Name=tag:k8s.io/role/node,Values=1" "Name=tag:KubernetesCluster,Values=$CLIENT_NAME-$i.jb.io" "Name=instance-state-code,Values=16" --output text | sort -k2f

echo "###################################"
echo "Printing all nodes IP's for cluster $CLIENT_NAME-$i.jb.io"
aws ec2 describe-instances --region=eu-west-1 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --filters  "Name=tag:KubernetesCluster,Values=$CLIENT_NAME-$i.jb.io" "Name=instance-state-code,Values=16" --output text | sort -k2f
        
done
