# Amazon EKS Setup

## Introduction

This document describes how to deploy [Wolfram Application Server (WAS)](https://www.wolfram.com/application-server/) onto Kubernetes hosted with [AWS cloud infrastructure](https://aws.amazon.com/).

This is a [Terraform](https://www.terraform.io/) based installation methodology that reliably automates the complete build, management and destruction processes of all resources. [Terraform](https://www.terraform.io/) is an [infrastructure-as-code](https://en.wikipedia.org/wiki/Infrastructure_as_code) command line tool that will create and configure all of the approximately 120 software and cloud infrastructure resources that are needed for running WAS on Kubernetes infrastructure. These Terraform scripts will install and configure all cloud infrastructure resources and system software on which WAS depends. This process will take around 15 minutes to complete and will generate copious amounts of console output.

Terraform will create a dedicated [AWS Virtual Private Network (VPC)](https://aws.amazon.com/vpc/) to contain all other resources that it creates. This VPC serves as an additional 'chinese wall' that prevents these AWS resources and system software packages from being able to interact with any other AWS resources that might already exist in your AWS account. This additional layer is strongly recommended, and you will incur negligable additional AWS cost for adding this additional layer of security protection.

The WAS application stack consists of the following:

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

Need to install terraform 1.3.3 to avoid issue with template library.

```console
brew uninstall terraform
brew install tfenv
TFENV_ARCH=amd64 tfenv install 1.3.3
tfenv use 1.3.3
```

Install other non-terraform libraries.

```console
$ brew install awscli kubernetes-cli helm k9s
```

### Configure the AWS CLI

To configure the AWS CLI run the following command:

```console
$ aws configure
```

This will interactively prompt for your AWS IAM user access key, secret key and preferred region.

### Install Helm charts

Helm helps you manage Kubernetes applications. Based on yaml 'charts', Helm helps you define, install, and upgrade even the most complex Kubernetes applications. Wolfram Application Server depends on multiple large complex subsystems, and fortunately, vendor-supported Helm charts are available for each of these.

Helm charts first need to be downloaded and added to your local Helm repository. The helm charts will be automatically executed by Terraform at the appropriate time, so there is nothing further that you need to do beyond adding these charts to your local helm repository.

```console
$ helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
$ helm repo add jetstack https://charts.jetstack.io
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
$ helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
$ helm repo add minio https://raw.githubusercontent.com/minio/operator/master/
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts/
$ helm repo add strimzi https://strimzi.io/charts/
$ helm repo add cowboysysop https://cowboysysop.github.io/charts/
$ helm repo update
```

### Setup Terraform

Terraform is a declarative open-source infrastructure-as-code software tool created by HashiCorp. This repo leverages Terraform to create all cloud infrastructure as well as to install and configure all software packages that run inside of Kubernetes. Terraform relies on an S3 bucket for storing its state data, and a DynamoDB table for managing a semaphore lock during operations.

Use these three environment variables for creating the uniquely named resources that the Terraform modules in this repo will be expecting to find at run-time.

**IMPORTANT: these three settings should be consistent with the values your set in terraform.tfvars in the next section.**

```console
$ AWS_ACCOUNT=012345678912      # add your 12-digit AWS account number here
$
$ AWS_REGION=us-east-2          # any valid AWS region code.
$ AWS_ENVIRONMENT=was           # any valid string. Keep it short -- 3 characters is ideal.
```

First create an AWS S3 Bucket

```console
AWS_S3_BUCKET="${AWS_ACCOUNT}-tfstate-${AWS_ENVIRONMENT}"
aws s3api create-bucket --bucket $AWS_S3_BUCKET --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
```

Then create a DynamoDB table

```console
$ AWS_DYNAMODB_TABLE="terraform-state-lock-${AWS_ENVIRONMENT}"
$ aws dynamodb create-table --region $AWS_REGION --table-name $AWS_DYNAMODB_TABLE  \
               --attribute-definitions AttributeName=LockID,AttributeType=S  \
               --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput  \
               ReadCapacityUnits=1,WriteCapacityUnits=1
```

## II. Build and Deploy WAS

### Step 1. Checkout the repository

```console
$ git clone https://github.com/WolframResearch/WAS-Kubernetes.git
$ cd WAS-Kubernetes
$ git checkout querium
```

### Step 2. Change directory to AWS

```console
$ cd ~/WAS-Kubernetes/EnvironmentSetup/AWS/
```

### Step 3. Configure your Terraform backend

Edit the following snippet so that bucket, region and dynamodb_table are consistent with your values of $AWS_REGION, $AWS_S3_BUCKET, $AWS_DYNAMODB_TABLE

```console
$ vim terraform/was/terraform.tf
```

```terraform
  backend "s3" {
    bucket         = "012345678912-tfstate-was"
    key            = "was/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock-was"
    profile        = "default"
    encrypt        = false
  }
````

### Step 4. Configure your environment by setting Terraform global variable values

```console
$ vim terraform/was/terraform.tfvars
```

Required inputs are as follows:

```terraform
account_id           = "012345678912"
aws_region           = "us-east-2"
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
azs                  = ["us-east-2a", "us-east-2b", "us-east-2c"]
private_subnets      = ["10.0.0.0/20"]
public_subnets       = ["10.0.48.0/20"]
cidr                 = "10.0.0.0/16"
cluster_version      = "1.27"
capacity_type        = "SPOT"
min_worker_node      = 2
desired_worker_node  = 2
max_worker_node      = 10
disk_size            = 100
instance_types       = ["t3.2xlarge", "t3a.2xlarge", "t2.2xlarge"]
```

### Step 5. Run the following command to set up EKS and deploy WAS

The Terraform modules in this repo rely extensively on calls to other third party Terraform modules published and maintained by [AWS](https://registry.terraform.io/namespaces/terraform-aws-modules). These modules will be downloaded by Terraform so that these can be executed locally from your computer. Noteworth examples of such third party modules include:

* [terraform-aws-modules/vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
* [terraform-aws-modules/eks](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)

```console
$ cd ~/WAS-Kubernetes/EnvironmentSetup/AWS/terraform/was
$ terraform init
```

Screen output should resemble the following:
![k9s home screen](https://raw.githubusercontent.com/QueriumCorp/WAS-Kubernetes/querium/EnvironmentSetup/AWS/doc/terraform-init.png "K9s Home Screen")

To deploy WAS run the following

```console
$ terraform apply
```

You can optionally run Terraform modules individually. Some examples include

```console
$ terraform apply -target=module.eks
$ aws eks update-kubeconfig --name was
$ terraform apply -target=module.kafka
$ terraform apply -target=module.minio
$ terraform apply -target=module.was
```

### Trouble Shooting

#### Error: Incompatible provider version

This is a known shortcoming of Terraform when run on macOS M1 platforms. See this [Terraform discussion forum thread](https://discuss.hashicorp.com/t/template-v2-2-0-does-not-have-a-package-available-mac-m1/35099/14) for trouble shooting ideas.

```console
│
│ Provider registry.terraform.io/hashicorp/template v2.2.0 does not have a package available for your current platform, darwin_arm64.
│
│ Provider releases are separate from Terraform CLI releases, so not all providers are available for all platforms. Other versions of this provider may have different platforms supported.
```

#### Error loading state: BucketRegionError: incorrect region, the bucket is not in

You'll encounter this error if the AWS region code in which you are attempting to deploy WAS does not match the region for the AWS S3 bucket you created.

#### Error: waiting for Security Group (sg-Odf68bde3fe22262d) Rule (sgrule-2953206013) create: couldn't find resource

![Error: waiting for Security Group](https://raw.githubusercontent.com/QueriumCorp/WAS-Kubernetes/querium/EnvironmentSetup/AWS/doc/error-waiting-for-sg.png "Error: waiting for Security Group")

Re-running `terraform apply` usually is successful.

#### Error: Error acquiring the state lock

Terraform sets a 'lock' in the AWS DynamoDB table that you created in the Terraform Setup above. If a Terraform operation fails then on your next operation attempt you will likely encounter the following error response, indicating that the Terraform state is currently locked.

```console
│ Error: Error acquiring the state lock
│
│ Error message: ConditionalCheckFailedException: The conditional request failed
│ Lock Info:
│   ID:        e1bd1079-86dc-0cd5-ea98-4d8c5ddb4d5a
│   Path:      320713933456-tfstate-was/was/terraform.tfstate
│   Operation: OperationTypeApply
│   Who:       ubuntu@ip-192-168-2-200
│   Version:   1.5.2
│   Created:   2023-07-10 17:11:39.939826727 +0000 UTC
│   Info:
│
│
│ Terraform acquires a state lock to protect the state from being written
│ by multiple users at the same time. Please resolve the issue above and try
│ again. For most commands, you can disable locking with the "-lock=false"
│ flag, but this is not recommended.

```

You can optionall execute the Terraform scripts without a lock, as follows:

```console
$ terraform apply -lock=false
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
$ AWS_REGION=us-east-2
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

![k9s home screen](https://raw.githubusercontent.com/QueriumCorp/WAS-Kubernetes/querium/EnvironmentSetup/AWS/doc/k8s-environment.png "K9s Home Screen")


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

![WAS error screen](https://raw.githubusercontent.com/QueriumCorp/WAS-Kubernetes/querium/EnvironmentSetup/AWS/doc/wolfram-welcome-screen.png "WAS error screen")


### Step 3. Install license

The filesystem directory where your Mathematica 'mathpass' file resides is shared between the web app server pods using an S3 bucket.
If you run a shell from k8s on one of the web app server pods (e.g. active-web-elements-server-deployment-HHHHHHHHHH-HHHHH), you can run the 'math' command to launch Mathematica from the shell.
Mathematica will display its version number (e.g. 13.1.0).  It will also prompt you for the password Wolfram gave you for WAS.
If the password you entered was valid, it should be saved by Mathematica in the filesystem, which should persist in S3:
```
cat /usr/local/Wolfram/WolframEngine/13.1/Configuration/Licensing/mathpass
active-web-elements-server-deployment-HHHHHHHHHH-HHHHH	HHHHHHHHHHHHHHHHHHHHHHHH	HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH	XXXXXXXXXXX	orgname	username
```

Running 'math' again should then go directly to the Mathematica prompt without requesting password information.

Within a few minutes, the mathpass file on this pod should be synchronized to the other active-web-elements-server-deployment pod.

NOTE: The following two methods for installing the mathpass file didn't work for us but are remain here for future reference.

The mathpass file needs to be deployed to WAS as a node file in the conventional location `.Wolfram/Licensing/mathpass`. From a Wolfram Language client, this may be achieved using the following code:

```javascript
    was = ServiceConnect["WolframApplicationServer", "https://example.com/"];
    ServiceExecute[was, "DeployNodeFile",
    {"Contents"-> File["/path/to/mathpass"], "NodeFile" -> ".Wolfram/Licensing/mathpass"}]
```

Alternatively, you may use the [node files REST API](../../Documentation/API/NodeFilesManager.md) to install the license file.

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
$ AWS_REGION=us-east-2
$ AWS_DYNAMODB_TABLE="terraform-state-lock-was"
$ AWS_S3_BUCKET="${AWS_ACCOUNT}-tfstate-was"
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
