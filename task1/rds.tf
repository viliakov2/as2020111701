resource "aws_db_instance" "magento" {
  identifier_prefix      = var.project_name
  allocated_storage      = var.rds_allocated_storage
  engine                 = var.rds_engine
  instance_class         = var.rds_instance_class
  name                   = var.magento_db_name
  username               = var.magento_db_username
  password               = var.magento_db_password
  vpc_security_group_ids = [aws_security_group.rds.id]
  engine_version         = var.rds_engine_version
  db_subnet_group_name   = aws_db_subnet_group.magento.name
  storage_type           = "gp2"
  multi_az               = var.rds_multi_az
  skip_final_snapshot    = true
  tags                   = var.common_tags
}

resource "aws_db_subnet_group" "magento" {
  name_prefix = var.project_name
  subnet_ids  = aws_subnet.db.*.id
  tags        = var.common_tags
}

resource "aws_security_group" "rds" {
  name   = "${var.project_name}-rds"
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ "Name" : "${var.project_name}-rds" }, var.common_tags)
}

resource "aws_security_group_rule" "rds_app_ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_bastion_ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.rds.id
}
