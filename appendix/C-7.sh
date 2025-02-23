#!/bin/bash
while read instance_id; do
  echo "임포트 대상 EC2 인스턴스 ID: $instance_id"
  terraform import "aws_instance.ec2_instances[\"$instance_id\"]" "$instance_id"
done < instance_ids.txt
