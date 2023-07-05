#!/bin/bash
#------------------------------------------------------------------------------
# written by:   Lawrence McDaniel
# date:         jul-2023
#
# usage:        build docker container
#               push to AWS ECR in the [Stepwise???] AWS account?
# 
#------------------------------------------------------------------------------
NOW="$(date +%Y%m%dT%H%M%S)"

REPOSITORY=aws-setup-manager
AWS_ECR_REGISTRY=320713933456.dkr.ecr.us-east-2.amazonaws.com
AWS_ECR_REPOSITORY=wolfram/${REPOSITORY}
AWS_ECR_REPOSITORY_TAG=$NOW


# -----------------------------------------------------------------------------
# II. build the Docker container
# -----------------------------------------------------------------------------

# note that this is most easily accomplished using a Cookiecutter bastion as this
# already includes all required software, and, awscli connectivity is already taken care of.
docker-compose up --build -d && clear && docker exec -it ${REPOSITORY} bash setup --endpoint-info

# -----------------------------------------------------------------------------
# II. push the image to AWS ECR
# -----------------------------------------------------------------------------

# login to AWS ECR
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 320713933456.dkr.ecr.us-east-2.amazonaws.com

# create the AWS ECR repo if it doesn't already exist
aws ecr describe-repositories --repository-names ${AWS_ECR_REPOSITORY} || aws ecr create-repository --repository-name ${AWS_ECR_REPOSITORY}

docker tag ${REPOSITORY}:latest ${AWS_ECR_REGISTRY}/${AWS_ECR_REPOSITORY}:${AWS_ECR_REPOSITORY_TAG}
docker tag ${REPOSITORY}:latest ${AWS_ECR_REGISTRY}/${AWS_ECR_REPOSITORY}:latest

docker push ${AWS_ECR_REGISTRY}/${AWS_ECR_REPOSITORY}:latest
docker push ${AWS_ECR_REGISTRY}/${AWS_ECR_REPOSITORY}:${AWS_ECR_REPOSITORY_TAG}

