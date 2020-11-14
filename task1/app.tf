resource "aws_autoscaling_group" "app" {
  name                      = var.project_name
  min_size                  = var.app_asg_min_size
  max_size                  = var.app_asg_max_size
  desired_capacity          = var.app_desired_capacity
  health_check_grace_period = 600
  health_check_type         = "EC2"
  vpc_zone_identifier       = aws_subnet.app.*.id
  target_group_arns         = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "app" {
  name_prefix            = "${var.project_name}-app"
  key_name               = aws_key_pair.app.key_name
  instance_type          = var.app_instance_type
  image_id               = data.aws_ami.amazon_linux.image_id
  vpc_security_group_ids = [aws_security_group.app.id]
  user_data = base64encode(templatefile("${path.module}/templates/app_user_data.sh", {
    aws_region                      = var.aws_region
    composer_username_ssm_name      = aws_ssm_parameter.composer_username.name
    composer_password_ssm_name      = aws_ssm_parameter.composer_password.name
    cloudfrount_url_ssm_name        = aws_ssm_parameter.cloudfrount_url.name
    efs_mount_target_ssm_name       = aws_ssm_parameter.efs_mount_target.name
    magento_lb_address_ssm_name     = aws_ssm_parameter.magento_lb_address.name
    magento_admin_user_ssm_name     = aws_ssm_parameter.magento_admin_user.name
    magento_admin_password_ssm_name = aws_ssm_parameter.magento_admin_password.name
    magento_db_host_ssm_name        = aws_ssm_parameter.magento_db_host.name
    magento_db_name_ssm_name        = aws_ssm_parameter.magento_db_name.name
    magento_db_username_ssm_name    = aws_ssm_parameter.magento_db_username.name
    magento_db_password_ssm_name    = aws_ssm_parameter.magento_db_password.name
    magento_redis_host_ssm_name     = aws_ssm_parameter.magento_redis_host.name
  }))
  tags = var.common_tags

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }
}

resource "aws_key_pair" "app" {
  key_name   = var.ec2_key_name
  public_key = var.ec2_public_key
}

resource "aws_lb" "app" {
  name               = var.project_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = aws_subnet.front.*.id
  tags               = var.common_tags
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group" "app" {
  name                 = var.project_name
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 60
  vpc_id               = aws_vpc.vpc.id
  health_check {
    interval = 10
    matcher  = "200,302"
  }
}

resource "aws_security_group" "lb" {
  name   = "${var.project_name}-lb"
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ "Name" : "${var.project_name}-lb" }, var.common_tags)
}

resource "aws_security_group_rule" "lb_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group" "app" {
  name   = "${var.project_name}-app"
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ "Name" : "${var.project_name}-app" }, var.common_tags)
}

resource "aws_security_group_rule" "app_ingress_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id
  security_group_id        = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_bastion_ingress_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_bastion_ingress_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-app"
  role = aws_iam_role.app.name
}

resource "aws_iam_role" "app" {
  name = "${var.project_name}-app"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags               = var.common_tags
}

resource "aws_iam_policy" "app" {
  name        = "${var.project_name}-app"
  path        = "/"
  description = "The app policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
            {
          "Effect": "Allow",
          "Action": [
              "ssm:DescribeParameters"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "ssm:PutParameter",
              "ssm:GetParameter"
          ],
          "Resource": "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/magento/*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "app" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app.arn
}
