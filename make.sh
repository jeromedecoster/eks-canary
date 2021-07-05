#!/bin/bash

#
# variables
#

# AWS variables
AWS_PROFILE=default
AWS_REGION=eu-west-3
# project name
PROJECT_NAME=eks-canary
# the directory containing the script file
PROJECT_DIR="$(cd "$(dirname "$0")"; pwd)"

export AWS_PROFILE AWS_REGION PROJECT_NAME PROJECT_DIR


log()   { echo -e "\e[30;47m ${1^^} \e[0m ${@:2}"; }        # $1 uppercase background white
info()  { echo -e "\e[48;5;28m ${1^^} \e[0m ${@:2}"; }      # $1 uppercase background green
warn()  { echo -e "\e[48;5;202m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background orange
error() { echo -e "\e[48;5;196m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background red

# https://unix.stackexchange.com/a/22867
export -f log info warn error

# log $1 in underline then $@ then a newline
under() {
    local arg=$1
    shift
    echo -e "\033[0;4m${arg}\033[0m ${@}"
    echo
}

usage() {
    under usage 'call the Makefile directly: make dev
      or invoke this file directly: ./make.sh dev'
}

# npm install + terraform init
setup() {
    cd "$PROJECT_DIR/test"
    npm install

    # terraform init
    cd "$PROJECT_DIR/infra"
    terraform init
}

# test canary deployment
test() {
    cd "$PROJECT_DIR/test"
    node .
}

# terraform validate
tf-validate() {
    cd "$PROJECT_DIR/infra"
    terraform fmt -recursive
    terraform validate
}

# terraform plan + terraform apply
tf-apply() {
    cd "$PROJECT_DIR/infra"
    terraform plan
    terraform apply -auto-approve
}

# setup kubectl config
kube-config() {
    cd "$PROJECT_DIR/infra"
    aws eks update-kubeconfig \
        --name $(terraform output -raw cluster_name) \
        --region $(terraform output -raw region)
}

# publish the 1.0.0 version
k8s-simple-1.0.0() {
    cd "$PROJECT_DIR/k8s-simple"
    kubectl apply --filename namespace.yaml
    kubectl apply --filename deployment-1-0-0.yaml
    kubectl apply --filename load-balancer-1.yaml

    # replace with loop + break if not empty test
    sleep 3
    LOAD_BALANCER=$(kubectl get services \
            hello-lb \
            --namespace canary-simple \
            --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    log LOAD_BALANCER $LOAD_BALANCER
}

# publish the 1.1.0 version as canary
k8s-simple-1.1.0-canary() {
    cd "$PROJECT_DIR/k8s-simple"
    kubectl scale --replicas=9 deployment hello-1-0-0 -n canary-simple
    kubectl apply --filename deployment-1-1-0.yaml
    kubectl apply --filename load-balancer-2.yaml
}

# deploy the 1.1.0 version
k8s-simple-1.1.0() {
    cd "$PROJECT_DIR/k8s-simple"
    kubectl scale --replicas=2 deployment hello-1-1-0 -n canary-simple
    kubectl apply --filename load-balancer-3.yaml
    kubectl delete deployments hello-1-0-0 -n canary-simple
}

# setup nginx using helm
k8s-nginx-setup() {
    kubectl create ns ingress-nginx

    helm install ingress-nginx ingress-nginx/ingress-nginx \
        --namespace ingress-nginx \
        --set controller.replicaCount=2 \
        --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
        --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
}

# publish the 1.0.0 version
k8s-nginx-1.0.0() {
    cd "$PROJECT_DIR/k8s-nginx"
    kubectl apply --filename prod-deploy.yaml
    kubectl apply --filename prod-ingress.yaml
}

# publish the 1.1.0 version as canary
k8s-nginx-1.1.0-canary() {
    cd "$PROJECT_DIR/k8s-nginx"
    kubectl apply --filename canary-deploy.yaml
    kubectl apply --filename canary-ingress-10.yaml
}

# deploy the 1.1.0 version
k8s-nginx-1.1.0() {
    cd "$PROJECT_DIR/k8s-nginx"
    kubectl apply --filename canary-ingress-100.yaml
    kubectl apply --filename prod-deploy-1-1-0.yaml
    kubectl delete ns hello-canary
}


# delete eks content + terraform destroy
destroy() {
    # uninstall nginx using installed using helm
    helm uninstall ingress-nginx --namespace ingress-nginx
    kubectl delete ns ingress-nginx

    # delete eks content
    kubectl delete ns hello-prod

    # terraform destroy
    cd "$PROJECT_DIR/infra"
    terraform destroy -auto-approve
}


# if `$1` is a function, execute it. Otherwise, print usage
# compgen -A 'function' list all declared functions
# https://stackoverflow.com/a/2627461
FUNC=$(compgen -A 'function' | grep $1)
[[ -n $FUNC ]] && { info execute $1; eval $1; } || usage;
exit 0
