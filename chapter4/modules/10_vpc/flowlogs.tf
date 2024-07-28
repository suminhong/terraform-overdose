###################################################
# VPC Flowlog
###################################################
locals {
  vpc_flowlogs   = var.attribute.vpc_flowlogs
  vpc_flowlog_cw = local.vpc_flowlogs.cloudwatch
  vpc_flowlog_s3 = local.vpc_flowlogs.s3
}

## VPC Flowlog to CloudWatch LogGroup
### IAM Role을 생성하지 않는 경우, data 블럭을 통해 Role 정보 가져오기
data "aws_iam_role" "flowlog" {
  count = (local.vpc_flowlog_cw.enable && !local.vpc_flowlog_cw.iam_role.create) ? 1 : 0
  name  = local.vpc_flowlog_cw.iam_role.name
}

### IAM Role을 직접 생성하는 경우
resource "aws_iam_role" "flowlog" {
  count = (local.vpc_flowlog_cw.enable && local.vpc_flowlog_cw.iam_role.create) ? 1 : 0
  name  = local.vpc_flowlog_cw.iam_role.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "CloudWatchLogGroupAccess"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
          ],
          "Resource" : "*"
        }
      ]
    })
  }

  tags = merge(
    var.tags,
    local.module_tag,
    {
      Name = local.vpc_flowlog_cw.iam_role.name
    },
  )
}

### CloudWatch LogGroup 생성
resource "aws_cloudwatch_log_group" "flowlog" {
  count             = local.vpc_flowlog_cw.enable ? 1 : 0
  name              = "/vpc/flowlog/${local.vpc_name}"
  retention_in_days = local.vpc_flowlog_cw.retention_in_days

  tags = merge(
    var.tags,
    local.module_tag,
    {
      Name = "${local.vpc_name}-Log-CW"
    },
  )
}

### LogGroup으로 향하는 FlowLog 구성
resource "aws_flow_log" "cw" {
  count           = local.vpc_flowlog_cw.enable ? 1 : 0
  iam_role_arn    = local.vpc_flowlog_cw.iam_role.create ? aws_iam_role.flowlog[count.index].arn : data.aws_iam_role.flowlog[count.index].arn
  log_destination = aws_cloudwatch_log_group.flowlog[count.index].arn
  traffic_type    = local.vpc_flowlog_cw.traffic_type
  vpc_id          = local.vpc_id

  tags = merge(
    var.tags,
    local.module_tag,
    {
      Name = "${local.vpc_name}-FlowLog-CW"
    },
  )
}

## VPC Flowlog to S3
### S3를 직접 생성하는 경우
resource "aws_s3_bucket" "flowlog" {
  count  = (local.vpc_flowlog_s3.enable && local.vpc_flowlog_s3.bucket.create) ? 1 : 0
  bucket = local.vpc_flowlog_s3.bucket.name

  tags = merge(
    var.tags,
    local.module_tag,
    {
      Name = local.vpc_flowlog_s3.bucket.name,
    }
  )
}

### S3로 향하는 FlowLog 구성
resource "aws_flow_log" "s3" {
  count                = local.vpc_flowlog_s3.enable ? 1 : 0
  vpc_id               = local.vpc_id
  log_destination_type = "s3"
  log_destination      = "arn:aws:s3:::${local.vpc_flowlog_s3.bucket.name}/"
  traffic_type         = local.vpc_flowlog_s3.traffic_type

  tags = merge(
    var.tags,
    local.module_tag,
    {
      Name = "${local.vpc_name}-FlowLog-S3"
    },
  )

  depends_on = [
    aws_s3_bucket.flowlog
  ]
}
