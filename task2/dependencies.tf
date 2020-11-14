data "aws_caller_identity" "current" {}

data "terraform_remote_state" "task1" {
  backend = "local"
  config = {
    path = "../task1/terraform.tfstate"
  }
}
