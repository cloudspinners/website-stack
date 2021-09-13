.DEFAULT_GOAL := help

STACK_CONFIG ?= my-stack-variables.tfvars
PLATFORM_CONFIG ?= my-platform-variables.tfvars
BACKEND_CONFIG ?= my-backend.hcl
include $(PLATFORM_CONFIG)
include $(STACK_CONFIG)

bundle:
	bundle install

bundleup:
	bundle update

init:
	cd src && terraform init -backend=true -backend-config=../$(BACKEND_CONFIG)

clean:
	rm -rf src/.terraform src/.terraform.lock.hcl

validate: init ## Validate syntax
	cd src && terraform validate

plan: init ## Show plan for apply
	cd src && terraform plan -var-file=../$(STACK_CONFIG) -var-file=../$(PLATFORM_CONFIG)

apply: init ## Apply code to the stack instance
	cd src && terraform apply -auto-approve -var-file=../$(STACK_CONFIG) -var-file=../$(PLATFORM_CONFIG)

destroy: init ## Destroy the stack instance
	cd src && terraform destroy -auto-approve -var-file=../$(STACK_CONFIG) -var-file=../$(PLATFORM_CONFIG)

plan-destroy: init ## Show the plan for destroy
	cd src && terraform plan -destroy -var-file=../$(STACK_CONFIG) -var-file=../$(PLATFORM_CONFIG)

output: init
	cd src && terraform output

_work/inspec_attributes_aws.yaml: init my-platform-variables.tfvars
	mkdir -p _work
	sed 's/[ \t]*=/:/' < my-platform-variables.tfvars > $@
	sed 's/[ \t]*=/:/' < my-stack-variables.tfvars >> $@
# 	( cd src && terraform output ) | sed 's/[ \t]*=/:/' >> $@

test: bundle _work/inspec_attributes_aws.yaml ## Run tests
	bundle exec inspec exec test/using_aws_api -t aws://$(aws_region)/$(aws_profile) --input-file=_work/inspec_attributes_aws.yaml

help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
