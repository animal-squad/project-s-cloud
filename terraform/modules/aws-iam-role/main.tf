resource "aws_iam_role" "role" {
  name_prefix           = var.name_prefix
  force_detach_policies = var.force_detach_policies

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name = "${var.name_prefix}-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = var.iam_policy_arn
}

//NOTE: IAM Role을 사용할수 있는 대상(Principal)
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      type        = var.principal_type
      identifiers = [var.principal_identifier]
    }
  }
}
