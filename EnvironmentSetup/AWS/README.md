# Amazon EKS Setup

## Introduction

This document describes the setup of Amazon Kubernetes (EKS) and Wolfram Application Server (WAS). 

This is a Terraform based, fully automated build-deploy script. Terraform is an infrastructure-as-code command line tool that will create and configure all required AWS resources, and install and configure all system software on which WAS depends. This process will take around 30 minutes to complete and will generate copious amounts of console output. Where possible Terraform uses Helm to install Kuberetes system softare packages.

The Amazon EKS stack consists of the following:

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

**WARNING: Terraform is a memory intensive application. For best results you should run this on a computer with at least 4Gib of free memory.**

## I. Install prerequisites

Quickstart for Linux & macOS operating systems.

**Prerequisite:** Obtain an [AWS IAM User](https://aws.amazon.com/iam/) with administrator priviledges, access key and secret key.

Ensure that your environment includes the latest stable releases of the following software packages:

* [aws cli](https://aws.amazon.com/cli/)
* [kubectl (Kubernetes cli)](https://kubernetes.io/docs/tasks/tools/)
* [terraform](https://www.terraform.io/)
* [helm](https://helm.sh/)
* [k9s](https://k9scli.io/)

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

To configure the AWS CLI run the following command:

```console
$ aws configure
```

This will interactively prompt for your AWS IAM user access key, secret key and preferred region.

Create Terraform required state management resources. Terraform uses a dediated AWS S3 bucket for storing its state data, and a DynamoDB table for managing a semphore lock during operations.

```console
$ AWS_ACCOUNT=012345678912      # add your 12-digit AWS account number here
$ AWS_REGION=us-east-1
$ AWS_DYNAMODB_TABLE="terraform-state-lock-was"
$ AWS_S3_BUCKET="${AWS_ACCOUNT}-terraform-tfstate-was"
```

Create an AWS S3 Bucket

```console
$ aws s3api create-bucket --bucket $AWS_S3_BUCKET --region $AWS_REGION
```

Create a DynamoDB table

```console
$ aws dynamodb create-table --region $AWS_REGION --table-name $AWS_DYNAMODB_TABLE  \
               --attribute-definitions AttributeName=LockID,AttributeType=S  \
               --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput  \
               ReadCapacityUnits=1,WriteCapacityUnits=1
```

## II. Build and deploy WAS

**Step 1.** Checkout the repository:

```console
$ git clone https://github.com/WolframResearch/WAS-Kubernetes.git
```

**Step 2.** Change directory to AWS:

```console
$ cd ~/WAS-Kubernetes/EnvironmentSetup/AWS/
```

**Step 3.** Configure your environment by setting Terraform global variable values:

```console
$ vim terraform/was/terraform.tfvars
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
$ cd ~/WAS-Kubernetes/EnvironmentSetup/AWS/terraform/was
$ terraform init
$ terraform apply
```

**Step 5.** Interact with the AWS EKS Kubernetes cluster

You can use k9s, a text-based gui, to view and interact with Kubernetes resources. k9s relies on kubectl to
communicate with the AWS EKS Kuberenetes cluster.

```console
$ k9s
```

If necessary, you can use the following command to refresh your kubectl authentication resources.

```console
$ aws eks --region us-east-1 update-kubeconfig --name was
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

## III. WAS Usage


**Step 1.** Interact with WAS

URL endpoints will be as follows, where <was.example.com> matches your value of services_subdomain above:

* Active Web Elements Server: https://was.example.com/
* Resource Manager: https://was.example.com/resources/
* Endpoints Manager: https://was.example.com/endpoints/
* Nodefiles: https://was.example.com/nodefiles/
* Endpoints Info: https://was.example.com/.applicationserver/info
* Restart AWES: https://was.example.com/.applicationserver/kernel/restart

**Step 2.** Get a license file from your Wolfram Research sales representative.

**Step 3.** This file needs to be deployed to WAS as a node file in the conventional location `.Wolfram/Licensing/mathpass`. From a Wolfram Language client, this may be achieved using the following code: 

    was = ServiceConnect["WolframApplicationServer", "https://example.com/"];
    ServiceExecute[was, "DeployNodeFile",
    {"Contents"-> File["/path/to/mathpass"], "NodeFile" -> ".Wolfram/Licensing/mathpass"}]


Alternatively you may use the [node files REST API](../../Documentation/API/NodeFilesManager.md) to install the license file.

**Note:** In order to use the Wolfram Language functions, the WolframApplicationServer paclet must be installed and loaded. Run the following code:

    PacletInstall["WolframApplicationServer"];
    Needs["WolframApplicationServer`"]

**Step 4.** Restart the application using the [restart API](../../Documentation/API/Utilities.md) to enable your Wolfram Engines.

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
