.DEFAULT_GOAL := help

##
## ansible
##
.PHONY: ping
ping: ssh-config test-gce.pem
	ansible -i "test-gce.us-west1-b.gcp-eval," -m ping all

.PHONY: playbook
playbook: ssh-config test-gce.pem
	ansible-playbook \
		-i "test-gce.us-west1-b.gcp-eval," \
		playbook.yml

.PHONY: ssh
ssh: ssh-config test-gce.pem
	ssh -F ssh-config test-gce.us-west1-b.gcp-eval

.PHONY: ssh-with-gcloud
ssh-with-gcloud: ssh-config test-gce.pem
	gcloud compute ssh test-gce

ssh-config: terraform.tfstate
	gcloud compute config-ssh \
		--ssh-config-file ssh-config \
		--ssh-key-file test-gce.pem

##
## terraform
##
options := -var 'cidr_home="'`curl -s http://ipecho.net/plain`/32'"'

.PHONY: plan
plan:  ## terraform plan with cidr_home
	terraform plan $(options) 

.PHONY: apply
apply:  ## terraform apply with cidr_home
	terraform apply $(options)

.PHONY: destroy
destroy:  ## terraform destroy with cidr_home
	terraform destroy $(options)

.PHONY: distclean
distclean:
	rm -f ssh-config test-gce.pem test-gce.pem.pub

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'
