resource "aws_autoscaling_group" "bastion" {
  name_prefix         = "${var.project_name}-bastion"
  min_size            = var.bastion_asg_min_size
  max_size            = var.bastion_asg_max_size
  desired_capacity    = var.bastion_desired_capacity
  vpc_zone_identifier = aws_subnet.front.*.id

  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "bastion" {
  name_prefix            = "${var.project_name}-bastion"
  key_name               = aws_key_pair.app.key_name
  instance_type          = var.bastion_instance_type
  image_id               = data.aws_ami.amazon_linux.image_id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  tags                   = var.common_tags
}

resource "aws_security_group" "bastion" {
  name   = "${var.project_name}-bastion"
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ "Name" : "${var.project_name}-bastion" }, var.common_tags)
}


resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}
