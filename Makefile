.SILENT:
.PHONY: test

help:
	{ grep --extended-regexp '^[a-zA-Z0-9._-]+:.*#[[:space:]].*$$' $(MAKEFILE_LIST) || true; } \
	| awk 'BEGIN { FS = ":.*#[[:space:]]*" } { printf "\033[1;32m%-24s\033[0m%s\n", $$1, $$2 }'

setup: # npm install + terraform init
	./make.sh setup

test: # test canary deployment
	./make.sh test

tf-validate: # terraform validate
	./make.sh tf-validate

tf-apply: # terraform plan + terraform apply
	./make.sh tf-apply

kube-config: # setup kubectl config
	./make.sh kube-config

k8s-simple-1.0.0: # publish the 1.0.0 version
	./make.sh k8s-simple-1.0.0

k8s-simple-1.1.0-canary: # publish the 1.1.0 version as canary
	./make.sh k8s-simple-1.1.0-canary

k8s-simple-1.1.0: # deploy the 1.1.0 version
	./make.sh k8s-simple-1.1.0

k8s-nginx-setup: # setup nginx using helm
	./make.sh k8s-nginx-setup

k8s-nginx-1.0.0: # publish the 1.0.0 version
	./make.sh k8s-nginx-1.0.0

k8s-nginx-1.1.0-canary: # publish the 1.1.0 version as canary
	./make.sh k8s-nginx-1.1.0-canary

k8s-nginx-1.1.0: # deploy the 1.1.0 version
	./make.sh k8s-nginx-1.1.0

destroy: # delete eks content + terraform destroy
	./make.sh destroy