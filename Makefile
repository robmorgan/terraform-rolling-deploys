.PHONY: all bake test init plan apply destroy help

all: help

bake: ## Bake a new AMI using Packer
	packer build packer/aws/app-server.json

test: ## Run the automated tests using Terratest
	cd test; go test -v -timeout 30m

init: ## Initialize Terraform to work locally
	terraform init

plan: ## Run the Terraform plan step
	terraform plan -var "ami=${AMI}"

apply: ## Run the Terraform apply step
	terraform apply -auto-approve -var "ami=${AMI}"

destroy: ## You probably don't know what you're doing
	terraform destroy -var "ami=${AMI}"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
