# Amazon EKS WAS Setup

## Introduction

This document describes the setup of Amazon Kubernetes (EKS) and Wolfram Application Server (WAS).

## Linux & macOS Setup

**Prerequisite:** Obtain an AWS IAM User with administrator priviledges, access key and secret key.

Ensure that your environment includes the following software packages:

* awscli
* kubectl (Kubernetes cli)
* terraform
* helm
* k9s

If necessary, install homebrew

```console
ubuntu@home:~$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ubuntu@home:~$ echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.profile
ubuntu@home:~$ eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Use homebrew to install all required packages.

```console
ubuntu@home:~$ brew install awscli kubernetes-cli terraform helm k9s
```

To configure the AWS CLI run the following command:

```console
ubuntu@home:~$ aws configure
```

This will interactively prompt for your AWS IAM user access key, secret key and preferred region.

Create Terraform required state management resources. Terraform uses a dediated AWS S3 bucket for storing its state data, and a DynamoDB table for managing a semphore lock during operations.

```console
ubuntu@home:~$ AWS_ACCOUNT=012345678912      # add your 12-digit AWS account number here
ubuntu@home:~$ AWS_REGION=us-east-1
ubuntu@home:~$ AWS_DYNAMODB_TABLE="terraform-state-lock-was"
ubuntu@home:~$ AWS_S3_BUCKET="${AWS_ACCOUNT}-terraform-tfstate-was"

# Create required Terraform state resources
ubuntu@home:~$ aws s3api create-bucket --bucket $AWS_S3_BUCKET --region $AWS_REGION
ubuntu@home:~$ aws dynamodb create-table --region $AWS_REGION --table-name $AWS_DYNAMODB_TABLE  \
               --attribute-definitions AttributeName=LockID,AttributeType=S  \
               --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput  \
               ReadCapacityUnits=1,WriteCapacityUnits=1
```

## Setup

**Step 1.** Checkout the repository:

```console
ubuntu@home:~$ git clone https://github.com/WolframResearch/WAS-Kubernetes.git
```

**Step 2.** Change directory to AWS:

```console
ubuntu@home:~$ cd ~/WAS-Kubernetes/EnvironmentSetup/AWS/Source
```

**Step 3.** Configure your environment:

```console
ubuntu@home:~$ vim terraform/was/terraform.tfvars
```

Rows 1 thru 12 of this file contain required inputs as follows

```terraform
account_id           = "012345678912"
aws_region           = "us-east-1"
aws_profile          = "default"
root_domain          = "example.com"
services_subdomain   = "was.example.com"
aws_auth_users       = []
kms_key_owners       = []
```

Additional optional inputs include the folowing:

```terraform
shared_resource_name = "was"
cidr                 = "10.168.0.0/16"
private_subnets      = ["10.168.128.0/18", "10.168.192.0/18"]
public_subnets       = ["10.168.0.0/18", "10.168.64.0/18"]
cluster_version      = "1.27"
capacity_type        = "SPOT"
min_worker_node      = 2
desired_worker_node  = 2
max_worker_node      = 10
disk_size            = 30
instance_types       = ["c5.2xlarge"]
```

**Step 4.** Run the following command to set up EKS and deploy WAS:

This takes around 30 minutes to complete.

```console
ubuntu@home:~$ cd ~/WAS-Kubernetes/EnvironmentSetup/AWS/Source/terraform/was
ubuntu@home:~$ terraform init
ubuntu@home:~$ terraform apply
```

**Note:** This can take approximately 45 minutes to complete.

**Step 5.** Interact with WAS

URL endpoints will be as follows, where <was.example.com> matches your value of services_subdomain above:

* Active Web Elements Server: https://was.example.com/
* Resource Manager: https://was.example.com/resources/
* Endpoints Manager: https://was.example.com/endpoints/
* Nodefiles: https://was.example.com/nodefiles/
* Endpoints Info: https://was.example.com/applicationserver/info
* Restart AWES: https://was.example.com/applicationserver/kernel/restart

**Step 6.** Get a license file from your Wolfram Research sales representative.

**Step 7.** This file needs to be deployed to WAS as a node file in the conventional location `.Wolfram/Licensing/mathpass`. From a Wolfram Language client, this may be achieved using the following code: 

    was = ServiceConnect["WolframApplicationServer", "https://example.com/"];
    ServiceExecute[was, "DeployNodeFile",
    {"Contents"-> File["/path/to/mathpass"], "NodeFile" -> ".Wolfram/Licensing/mathpass"}]


Alternatively you may use the [node files REST API](../../Documentation/API/NodeFilesManager.md) to install the license file.

**Note:** In order to use the Wolfram Language functions, the WolframApplicationServer paclet must be installed and loaded. Run the following code:

    PacletInstall["WolframApplicationServer"];
    Needs["WolframApplicationServer`"]

**Step 8.** Restart the application using the [restart API](../../Documentation/API/Utilities.md) to enable your Wolfram Engines.

URL: `https://example.com/.applicationserver/kernel/restart`
	
The default credentials for this API are: 
	
	Username: applicationserver
	
	Password: P7g[/Y8v?KR}#YvN


To change these, see the [configuration documentation](../../Configuration.md).

**Note:** Active Web Elements Server will restart and activate using the mathpass. Upon successful activation, the application shall start. 

Your setup is now complete.


## Remove the cluster and all associated AWS resources

```console
ubuntu@home:~$ cd ~/WAS-Kubernetes/EnvironmentSetup/AWS/Source/terraform/was
ubuntu@home:~$ terraform init
ubuntu@home:~$ terraform destroy
```

Delete Terraform state management resources

```console
ubuntu@home:~$ AWS_REGION=us-east-1
ubuntu@home:~$ AWS_DYNAMODB_TABLE="terraform-state-lock-was"
ubuntu@home:~$ aws dynamodb delete-table --region $AWS_REGION --table-name $AWS_DYNAMODB_TABLE
```

The following completely deletes everything including the kubernetes cluster, Wolfram Application Server and all resources:
