# 3_tier

## firstly we need aws congiure to use terraform
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws configure


## install terraform

 sudo apt update -y

 curl -O https://releases.hashicorp.com/terraform/1.10.3/terraform_1.10.3_linux_amd64.zip
 {this is              AMD64  Version: 1.10.3   to install terraform}

 apt install unzip

 unzip terraform_1.10.3_linux_amd64.zip

 mv ./terraform /bin/

## attach IAM role
{ to use aws in terraform }