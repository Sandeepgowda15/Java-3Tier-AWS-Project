resource "aws_iam_role" "app_ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-ec2-role"
    Project = var.project_name
    Tier    = "application"
  }
}


resource "aws_iam_role_policy_attachment" "app_ec2_ssm" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy" "app_ec2_secrets" {
  name = "${var.project_name}-secrets-policy"
  role = aws_iam_role.app_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = aws_db_instance.mysql.master_user_secret[0].secret_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "app_ec2_s3" {
  name = "${var.project_name}-s3-policy"
  role = aws_iam_role.app_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "arn:aws:s3:::java-3tier-app-deploy-089783390772/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "app_ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.app_ec2_role.name

  tags = {
    Name    = "${var.project_name}-ec2-profile"
    Project = var.project_name
    Tier    = "application"
  }
}
