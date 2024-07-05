import pulumi
from pulumi_aws import ec2

def main():
    # VPC에 존재하는 모든 서브넷 가져오기
    subnets = ec2.get_subnet_ids(vpc_id="vpc-123456").ids

    # 서브넷의 태그를 보고 인스턴스 수를 결정하는 함수 호출
    instance_count = calculate_instance_count(subnets)

    # EC2 인스턴스 생성
    for i in range(instance_count):
        instance = ec2.Instance(
            f"instance-{i}",
            instance_type="t2.micro",
            ami="ami-0c55b159cbfafe1f0",
            subnet_id=subnets[i % len(subnets)],
        )

    # 생성된 EC2 인스턴스의 아이디 내보내기
    pulumi.export(f"instance_id_{i}", instance.id)

pulumi.run(main)
