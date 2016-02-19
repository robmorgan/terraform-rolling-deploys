.PHONY: all bake plan apply destroy

ASG_NAME=$(shell terraform output asg_name)

all: bake plan apply

bake:
	packer build packer/aws/app-server.json

plan:
	terraform plan -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" -var "ami=${AMI}"

apply:
	terraform apply -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" -var "ami=${AMI}"

destroy:
	terraform destroy -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}"
