#!/bin/bash

# 변수
AMI_ID="ami-0abcdef1234567890"
SECURITY_GROUP_ID="sg-0123456789abcdef0"
SUBNET_ID="subnet-0123456789abcdef0"
INSTANCE_TYPE="t3.micro"
KEY_NAME="your-key-pair-name"
AWS_REGION="ap-northeast-2"

# EC2 인스턴스 100개 생성
for i in {1..100}; do
  INSTANCE_ID=$(aws ec2 run-instances \
	--image-id $AMI_ID \
	--instance-type $INSTANCE_TYPE \
	--key-name $KEY_NAME \
	--security-group-ids $SECURITY_GROUP_ID \
	--subnet-id $SUBNET_ID \
	--query 'Instances[0].InstanceId' \
	--output text \
	--region $AWS_REGION)

  echo "생성된 EC2 인스턴스 ID: $INSTANCE_ID"

  # 인스턴스에 태그 지정
  aws ec2 create-tags \
      --resources $INSTANCE_ID \
      --tags Key=Name,Value=Instance-$i \
      --region $AWS_REGION
done

echo "EC2 인스턴스 100개 생성 완료"
