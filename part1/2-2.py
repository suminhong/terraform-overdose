def calculate_instance_count(subnet_ids):
    total_instances = 0

    for subnet_id in subnet_ids:
        subnet = ec2.get_subnet(id=subnet_id)
        size_tag = subnet.tags.get("Size")

        if not size_tag:
            continue

        if size_tag == "Single":
            total_instances += 5
        elif size_tag == "Double":
            total_instances += 10

    return total_instances
