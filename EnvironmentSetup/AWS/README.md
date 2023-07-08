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
ubuntu@user:~$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ubuntu@user:~$ echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.profile
ubuntu@user:~$ eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Use homebrew to install all required packages.

```console
ubuntu@user:~$ brew install awscli kubernetes-cli terraform helm k9s
```

To configure the AWS CLI run the following command:

```console
ubuntu@user:~$ aws configure
```

This will interactively prompt for your AWS IAM user access key, secret key and preferred region.

## Setup

**Step 1.** Checkout the repository:

```console
ubuntu@user:~$ git clone https://github.com/WolframResearch/WAS-Kubernetes.git
```

**Step 2.** Change directory to AWS:

```console
ubuntu@user:~$ cd ~/WAS-Kubernetes/EnvironmentSetup/AWS/Source
```

**Step 3.** Configure your environment:

```console
ubuntu@user:~$ vim terraform/was/terraform.tfvars
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

```console
ubuntu@user:~$ setup
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


## Remove the cluster

The following completely deletes everything including the kubernetes cluster, Wolfram Application Server and all resources:

**Step 1.** Update the `terraform/variables.tf` file with your WAS cluster info(aws_region, cluster name etc.)

**Step 2.** Change your directory to the directory containing `docker-compose.yml` directory and run the following command to destroy your EKS cluster and WAS:

	docker-compose up --build -d && clear && docker exec -it aws-setup-manager bash setup --delete

**Warning:** All data will be destroyed.

**Step 2.** After completion, shutdown the aws-setup-manager by running the following command:

	docker-compose down	-v

---

## Troubleshooting

**1.** Backend configuration is changed error.
```
Building EKS - (can take upto 30 minutes) [ERROR] Failed with error: 1
[ ✘ ]

[ERROR] Something went wrong. Exiting.
[ERROR] The last few log entries were:
╷
│ Error: Backend configuration changed
│
│ A change in the backend configuration has been detected, which may require
│ migrating existing state.
│
│ If you wish to attempt automatic migration of the state, use “terraform
│ init -migrate-state”.
│ If you wish to store the current configuration with no changes to the
│ state, use “terraform init -reconfigure”.
```

You need to check these bullet-points.

* Check S3/DynamoDb for previous WAS setup states. If any of them exists, remove it manually on AWS Console.

  

* Remove docker container cache.

  * Stop the running `aws-setup-manager` container with `docker kill <CONTAINER_ID>`
  * `docker container prune -f`
  * `docker volume prune -a -f`
