# git-runner-self-hosted-aws
This code enables the github runner automation in autoscaling on AWS.

Phase 1: Github Runner Setup
a) Variablize the github runner commands
b) Use these variables in userdata.tmpl and terrafrom.tfvars

Phase 2: Userdata with pre-requisite
a) Define the pre-requisites in the userdata
    # Insall pre-requisite
    yum update -y
    sudo yum install -y libicu
b) Create the service of github runner and enable it run in backend
    cd /home/ec2-user/actions-runner/ && ./svc.sh install && ./svc.sh start

Phase 3: Auto Scaling template
a) Use the latest AMI Linux image
    Github Runner setup commands will vary basis the OS and Architect selection 
b) UserData to be used for scale out with github runner variables
c) Add the SSM role for easy management
d) Call the Launch template in auto scaling resource

Since, github runner is set to never expire. Hence, sam token can be used later to scale-out the runner instances.

