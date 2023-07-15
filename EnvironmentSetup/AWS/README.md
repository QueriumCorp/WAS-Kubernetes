# Amazon EKS Setup

## Introduction

This document describes how to deploy [Wolfram Application Server (WAS)](https://www.wolfram.com/application-server/) onto Kubernetes hosted with [AWS cloud infrastructure](https://aws.amazon.com/).

This is a [Terraform](https://www.terraform.io/) based installation methodology that reliably automates the complete build, management and destruction processes of all resources. [Terraform](https://www.terraform.io/) is an [infrastructure-as-code](https://en.wikipedia.org/wiki/Infrastructure_as_code) command line tool that will create and configure all of the approximately 120 software and cloud infrastructure resources that are needed for running WAS on Kubernetes infrastructure. These Terraform scripts will install and configure all cloud infrastructure resources and system software on which WAS depends. This process will take around 15 minutes to complete and will generate copious amounts of console output.

Terraform will create a dedicated [AWS Virtual Private Network (VPC)](https://aws.amazon.com/vpc/) to contain all other resources that it creates. This VPC serves as an additional 'chinese wall' that prevents these AWS resources and system software packages from being able to interact with any other AWS resources that might already exist in your AWS account. This additional layer is strongly recommended, and you will incur negligable additional AWS cost for adding this additional layer of security protection.

The WAS [AWS Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/) application stack consists of the following:

* a AWS S3 bucket and DynamoDB table for managing Terraform state
* a dedicated [AWS VPC](https://aws.amazon.com/vpc/)
* a dedicated [AWS EKS Kubernetes cluster](https://aws.amazon.com/eks/)
  * a configurable [Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) with on-demand and spot-priced tier options
  * AWS EKS Add-on [EFS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
  * AWS EKS Add-on [EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
  * AWS EKS Add-on [VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)
  * AWS EKS Add-on [kube-proxy](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)
  * AWS EKS Add-on [CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)
* Kubernetes [Vertical Pod Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/vertical-pod-autoscaler.html)
* Kubernetes [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
* Kubernetes [Prometheus](https://prometheus.io/)
* Kubernetes [cert-manager](https://cert-manager.io/)
* Kubernetes [Nginx Ingress Controller](https://docs.nginx.com/nginx-ingress-controller/)
* Kubernetes [Minio](https://bitnami.com/stack/minio/helm)
* Kubernetes [Kakfa](https://bitnami.com/stack/kafka/helm)
* [Wolfram Application Server](https://www.wolfram.com/application-server/)

**WARNINGS**:

**1. The EKS service will create many AWS resources in other parts of your AWS account including EC2, VPC, IAM and KMS. You should not directly modify any of these resources, as this could lead to unintended consequences in the safe operation of your Kubernetes cluster up to and including permanent loss of access to the cluster itself.**

**2. Terraform is a memory intensive application. For best results you should run this on a computer with at least 4Gib of free memory.**

## I. Installation Prerequisites

Quickstart for Linux & macOS operating systems.

**Prerequisite:** Obtain an [AWS IAM User](https://aws.amazon.com/iam/) with administrator priviledges, access key and secret key.

Ensure that your environment includes the latest stable releases of the following software packages:

* [aws cli](https://aws.amazon.com/cli/)
* [kubectl (Kubernetes cli)](https://kubernetes.io/docs/tasks/tools/)
* [terraform](https://www.terraform.io/)
* [helm](https://helm.sh/)
* [k9s](https://k9scli.io/)

### Install required software packages using Homebrew

If necessary, install [Homebrew](https://brew.sh/)

```console
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
$ echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.profile
$ eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Use homebrew to install all required packages.

```console
$ brew install awscli kubernetes-cli terraform helm k9s
```

### Configure the AWS CLI

To configure the AWS CLI run the following command:

```console
$ aws configure
```

This will interactively prompt for your AWS IAM user access key, secret key and preferred region.

### Install Helm charts

Helm helps you manage Kubernetes applications. Based on yaml 'charts', Helm helps you define, install, and upgrade even the most complex Kubernetes applications. Wolfram Application Server depends on multiple large complex subsystems, and fortunately, vendor-supported Helm charts are available for each of these.

Helm charts first need to be downloaded and added to your local Helm repository.

```console
$ helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
$ helm repo add jetstack https://charts.jetstack.io
$ helm repo add ingress-nginx https://github.com/kubernetes/ingress-nginx
$ helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
$ helm repo add minio https://raw.githubusercontent.com/minio/operator/master/
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts/
$ helm repo add strimzi https://strimzi.io/charts/
$ helm repo add cowboysysop https://cowboysysop.github.io/charts/
$ helm repo update
```

### Setup Terraform

Terraform is a declarative open-source infrastructure-as-code software tool created by HashiCorp. This repo leverages Terraform to create all cloud infrastructure as well as to install and configure all software packages that run inside of Kubernetes. Terraform relies on an S3 bucket for storing its state data, and a DynamoDB table for managing a semaphore lock during operations.

Use these environment variables for creating consistnent, unique resources names for these two objects.

```console
$ AWS_ACCOUNT=012345678912      # add your 12-digit AWS account number here
$ AWS_REGION=us-east-1
```

First create an AWS S3 Bucket

```console
$ AWS_S3_BUCKET="${AWS_ACCOUNT}-terraform-tfstate-was"
$ aws s3api create-bucket --bucket $AWS_S3_BUCKET --region $AWS_REGION
```

Then create a DynamoDB table

```console
$ AWS_DYNAMODB_TABLE="terraform-state-lock-was"
$ aws dynamodb create-table --region $AWS_REGION --table-name $AWS_DYNAMODB_TABLE  \
               --attribute-definitions AttributeName=LockID,AttributeType=S  \
               --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput  \
               ReadCapacityUnits=1,WriteCapacityUnits=1
```

## II. Build and Deploy WAS

### Step 1. Checkout the repository

```console
$ git clone https://github.com/WolframResearch/WAS-Kubernetes.git
```

### Step 2. Change directory to AWS

```console
$ cd ~/WAS-Kubernetes/EnvironmentSetup/AWS/
```

### Step 3. Configure your environment by setting Terraform global variable values

```console
$ vim terraform/was/terraform.tfvars
```

Required inputs are as follows:

```terraform
account_id           = "012345678912"
aws_region           = "us-east-1"
domain               = "example.com"
shared_resource_name = "was"
```

And there are additional optional inputs include the folowing:

Of particular interest

```terraform
was_active_web_elements_server_version  = "3.1.5"
was_endpoint_manager_version            = "1.2.1"
was_resource_manager_version            = "1.2.1"
```

and less so, but worth mentioning

```terraform
tags                 = {}
aws_profile          = "default"
aws_auth_users       = []
kms_key_owners       = []
shared_resource_name = "was"
cidr                 = "192.168.0.0/20"
private_subnets      = ["192.168.4.0/24", "192.168.5.0/24"]
public_subnets       = ["192.168.1.0/24", "192.168.2.0/24"]
cluster_version      = "1.27"
capacity_type        = "SPOT"
min_worker_node      = 2
desired_worker_node  = 2
max_worker_node      = 10
disk_size            = 30
instance_types       = ["t3.2xlarge", "t3a.2xlarge", "t2.2xlarge"]
```

### Step 4. Run the following command to set up EKS and deploy WAS

The Terraform modules in this repo rely extensively on calls to other third party Terraform modules published and maintained by [AWS](https://registry.terraform.io/namespaces/terraform-aws-modules). These modules will be downloaded by Terraform so that these can be executed locally from your computer. Noteworth examples of such third party modules include:

* [terraform-aws-modules/vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
* [terraform-aws-modules/eks](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)

```console
$ cd ~/WAS-Kubernetes/EnvironmentSetup/AWS/terraform/was
$ terraform init
$ terraform apply
```

To deployment WAS run the following

```console
$ terraform apply
```

You can optionally run Terraform modules individually. Some examples include

```console
$ terraform apply -target=module.eks
$ terraform apply -target=module.kafka
$ terraform apply -target=module.minio
$ terraform apply -target=module.was
```

### Step 5. Interact with the AWS EKS Kubernetes cluster

You can use k9s, a text-based gui, to view and interact with Kubernetes resources. k9s relies on kubectl to
communicate with the AWS EKS Kuberenetes cluster.

```console
$ k9s
```

If necessary, you can use the following command to refresh your kubectl authentication resources.

First, configure kubectl to connect to your AWS EKS Kubernetes cluster.

```console
$ AWS_REGION=us-east-1
$ EKS_CLUSTER_NAME=was
$ aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME --alias $EKS_CLUSTER_NAME
```

Use this command to verify that kubectl can access Kubernetes cluster resources.

```console
$ kubectl get namespaces
NAME                 STATUS   AGE
default              Active   3h
ingress-controller   Active   101m
kafka                Active   100m
kube-node-lease      Active   3h
kube-public          Active   3h
kube-system          Active   3h
metrics-server       Active   106m
prometheus           Active   105m
vpa                  Active   106m
was                  Active   100m
```

Run k9s from your command line

```console
$ k9s
```

After successfully running the Terraform script the k9s home screen should look similiar to the following:

![k9s home screen](https://raw.githubusercontent.com/QueriumCorp/WAS-Kubernetes/mcdaniel-20230706/EnvironmentSetup/AWS/doc/wolfram-welcome-screen.png "K9s Home Screen")


## III. WAS Usage

### Step 1. Interact with WAS

URL endpoints will be as follows, where <was.example.com> matches your value of services_subdomain above:

* Active Web Elements Server: https://was.example.com/
* Resource Manager: https://was.example.com/resources/
* Endpoints Manager: https://was.example.com/endpoints/
* Nodefiles: https://was.example.com/nodefiles/
* Endpoints Info: https://was.example.com/.applicationserver/info
* Restart AWES: https://was.example.com/.applicationserver/kernel/restart

### Step 2. Get a license file from your Wolfram Research sales representative

The WAS home screen will return this error message until you add a valid software license key.

![WAS error screen](https://raw.githubusercontent.com/QueriumCorp/WAS-Kubernetes/mcdaniel-20230706/EnvironmentSetup/AWS/doc/wolfram-welcome-screen.png "WAS error screen")


### Step 3. Install license

This file needs to be deployed to WAS as a node file in the conventional location `.Wolfram/Licensing/mathpass`. From a Wolfram Language client, this may be achieved using the following code:

```javascript
    was = ServiceConnect["WolframApplicationServer", "https://example.com/"];
    ServiceExecute[was, "DeployNodeFile",
    {"Contents"-> File["/path/to/mathpass"], "NodeFile" -> ".Wolfram/Licensing/mathpass"}]
```



Alternatively you may use the [node files REST API](../../Documentation/API/NodeFilesManager.md) to install the license file.

**Note:** In order to use the Wolfram Language functions, the WolframApplicationServer paclet must be installed and loaded. Run the following code:

```javascript
    PacletInstall["WolframApplicationServer"];
    Needs["WolframApplicationServer`"]
```

### Step 4. Restart

Restart the application using the [restart API](../../Documentation/API/Utilities.md) to enable your Wolfram Engines.

URL: `https://example.com/.applicationserver/kernel/restart`

The default credentials for this API are:

	Username: applicationserver

	Password: P7g[/Y8v?KR}#YvN


To change these, see the [configuration documentation](../../Configuration.md).

**Note:** Active Web Elements Server will restart and activate using the mathpass. Upon successful activation, the application shall start.

Your setup is now complete.


## IV. Uninstall

The following completely destroys everything including the kubernetes cluster, Wolfram Application Server and all resources:

```console
$ cd ~/WAS-Kubernetes/EnvironmentSetup/AWS/Source/terraform/was
$ terraform init
$ terraform destroy
```

Delete Terraform state management resources

```console
$ AWS_ACCOUNT=012345678912      # add your 12-digit AWS account number here
$ AWS_REGION=us-east-1
$ AWS_DYNAMODB_TABLE="terraform-state-lock-was"
$ AWS_S3_BUCKET="${AWS_ACCOUNT}-terraform-tfstate-was"
```

To delete the DynamoDB table

```console
$ aws dynamodb delete-table --region $AWS_REGION --table-name $AWS_DYNAMODB_TABLE
```

To delete the AWS S3 bucket

```console
$ aws s3 rm s3://$AWS_S3_BUCKET --recursive
$ aws s3 rb s3://$AWS_S3_BUCKET --force
```
