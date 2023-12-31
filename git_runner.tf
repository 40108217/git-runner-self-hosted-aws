data "aws_availability_zones" "all_azs" {
  state = "available"
}
data "aws_ami" "latest_amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.2.*-x86_64"]
  }
  owners = ["amazon"] # Canonical
}


resource "aws_launch_template" "ec2_launch_template" {
  name        = "github_runner_launch_template"
  description = "Launch Template for GitHub Runners EC2 AutoScaling Group"
  #ami           = data.aws_ami.latest_amazon_linux_2.id
  #instance_type = "t2.micro"
  #iam_instance_profile = aws_iam_instance_profile.veru-ssm-role.name
  image_id      = var.ami
  instance_type = var.instance_type
  #key_name      = var.key_name
  user_data = base64encode(templatefile("${path.cwd}/userdata.tmpl", { github_repo_url = var.github_repo_url, github_repo_pat_token = var.github_repo_pat_token, runner_name = var.runner_name, labels = join(",", var.labels) }))
  
  iam_instance_profile {
    name = aws_iam_instance_profile.veru-ssm-role.name
  }

  
  tags = {
    Name = "github_runner"
  }
}

# Imported this resource from AWS
resource "aws_iam_instance_profile" "veru-ssm-role" {
  name = "veru-ssm-role"
  role = "veru-ssm-role"
}


resource "aws_autoscaling_group" "github_runners_autoscaling_group" {
  name                      = "github_runners_autoscaling_group"
  availability_zones        = data.aws_availability_zones.all_azs.names
  health_check_type         = "EC2"
  health_check_grace_period = var.health_check_grace_period
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
}