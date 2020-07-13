#!/bin/bash
#source ~/.bash_profile
CLIENT_NAME=`hostid`
NUMBER_CLUSTERS=$1
VPC="vpc-d7d6e4b1" # jb account
SUBNET_ID_A="subnet-1042eb4a" # jb account
DNS_ZONE=Z3S7L7JR4B7VHI

# number of servers required 
for i in {1..1}

do
    export NAME="$CLIENT_NAME-$i.jb.io"
    echo "the name is $NAME"
    export KOPS_STATE_STORE="s3://jb-cloud-terraform-vpc-remote-state"
    export ZONES="eu-west-1a"
    export NETWORK_CIDR=172.31.0.0/16
    echo "Creating folder"
    mkdir -p ./$CLIENT_NAME/clusters/cluster-$i
    cp *.tf ./$CLIENT_NAME/clusters/cluster-$i
    kops create cluster \
                --master-zones $ZONES \
                --dns private \
                --dns-zone $DNS_ZONE \
                --master-size=t2.small \
                --node-size=t2.medium \
                --zones $ZONES \
                --topology public \
                --node-count=1 \
                --master-count=1 \
                --master-volume-size=16 \
                --node-volume-size=16 \
                --networking=calico  \
                --out=./$CLIENT_NAME/clusters/cluster-$i/ \
                --target=terraform \
                --vpc $VPC \
                --subnets $SUBNET_ID_A \
                ${NAME}
    sed -i 's/jb-cloud-infra-k8s/jb-cloud-infra-k8s-'$CLIENT_NAME'-'$i'a/g' ./$CLIENT_NAME/clusters/cluster-$i/s3_state.tf
    echo "Changing instances to spots"
    sed -i '/user_data/a spot_price="0.070"' ./$CLIENT_NAME/clusters/cluster-$i/kubernetes.tf
    echo "Welcome ${NAME} cluster number $i"
    
    echo "Applying Terraform"
    cd $CLIENT_NAME/clusters/cluster-$i/
    terraform init -input=false
    terraform workspace new jb-eu-west-1 || true
    terraform workspace select jb-eu-west-1 || true
    terraform plan -out=tfplan -input=false
    terraform apply -input=false tfplan 
    echo "Dir on exit"
    cd ../../../
    pwd
    
done

echo "Printing all Master IP's for cluster $CLIENT_NAME-$i.jb.io"
aws ec2 describe-instances --region=eu-west-1 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --filters "Name=tag:k8s.io/role/master,Values=1"  "Name=instance-state-code,Values=16" --output text | sort -k2f
echo "################################"

echo "###################################"
echo "Printing all nodes IP's for cluster $CLIENT_NAME-$i.jb.io"
aws ec2 describe-instances --region=eu-west-1 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --filters  "Name=tag:KubernetesCluster,Values=$CLIENT_NAME" "Name=instance-state-code,Values=16" --output text | sort -k2f

aws ec2 describe-instances --region=eu-west-1 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --filters  "Name=instance-state-code,Values=16" --output text | sort -k2f


