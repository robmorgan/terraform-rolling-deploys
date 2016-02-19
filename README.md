# Terraform Rolling Deployment Demo

This is a demo project that accompanies a blog post I wrote.
It shows how to use various tools from the Hashicorp stack to achieve rolling
deployments on AWS with zero downtime.

The post is here: http://robmorgan.id.au/post/139602239473/rolling-deploys-on-aws-using-terraform

It is based on a concept from Paul Hinze:
https://groups.google.com/forum/#!msg/terraform-tool/7Gdhv1OAc80/iNQ93riiLwAJ

## Architecture

![terraform aws architecture - current architecture](https://cloud.githubusercontent.com/assets/178939/13179538/9cbc9aec-d724-11e5-91e4-77b9a06ebdc6.png)

## Requirements

You should have the following tools installed:

* Git
* Packer
* Terraform

Additionally you will need the following environment variables set:

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY

## Usage

1. Before we create the AWS infrastructure we must first _bake_ a new AMI using Packer.
Using the supplied `Makefile`, simply run:

```
$ make bake
```

When Packer finishes running it will output an AMI ID we need for the next step.

2. Now we can use Terraform to create the AWS resources:

```
$ make plan AMI="ami-XXXYYYZZ"
$ make apply AMI="ami-XXXYYYZZ"
```

3. Deployment is a case of baking a fresh AMI then re-running Terraform:

```
$ make bake
$ make plan AMI="ami-XXXYYYZZ"
$ make apply AMI="ami-XXXYYYZZ"
```
