data "aws_ami" "latest_amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.2.*-x86_64"]
  }
  owners = ["amazon"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.latest_amazon_linux_2.id
  instance_type = "t2.micro"
  user_data = <<-EOF
  #!/bin/bash
  sudo yum update
  sudo yum install -y git
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  sudo yum -y install terraform
  sudo cd /usr/local
  sudo mkdir actions-runner && cd actions-runner
  sudo curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
  sudo tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
  sudo yum install -y libicu
  exit
  ./config.sh --url https://github.com/40108217/git-runner-self-hosted-aws --token AOD4MDTEV6SXZPZNBPP7WZ3FIHRNO
  sudo ./svc.sh install
  sudo ./svc.sh start
  EOF
/*
Here below is the sample of runner service automation :-

[Unit]
Description=GitHub Actions Runner (40108217-git-runner-self-hosted-aws.git-runner-01)
After=network.target

[Service]
ExecStart=/etc/actions-runner/runsvc.sh
User=ssm-user
WorkingDirectory=/etc/actions-runner
KillMode=process
KillSignal=SIGTERM
TimeoutStopSec=5min

[Install]
WantedBy=multi-user.target */

  tags = {
    Name = "git-runner-selfhosted"
  }
}

