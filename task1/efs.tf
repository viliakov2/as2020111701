resource "aws_efs_file_system" "magento" {
  creation_token = var.project_name
  tags           = var.common_tags
}

resource "aws_efs_mount_target" "magento" {
  count           = length(var.vpc_app_subnets)
  file_system_id  = aws_efs_file_system.magento.id
  subnet_id       = aws_subnet.app[count.index].id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name   = "${var.project_name}-efs"
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ "Name" : "${var.project_name}-efs" }, var.common_tags)
}

resource "aws_security_group_rule" "efs_app_ingress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.efs.id
}

resource "aws_security_group_rule" "efs_bastion_ingress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.efs.id
}
