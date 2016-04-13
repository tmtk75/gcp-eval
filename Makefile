.PHONEY: ping playbook ssh plan apply

ping: ssh-config test-gce.pem
	ansible -i "test-gce.asia-east1-c.gcp-eval," -m ping all

playbook: ssh-config test-gce.pem
	ansible-playbook -i "test-gce.asia-east1-c.gcp-eval," playbook.yml \
	  -e domain=$(domain) -e mail_address=$(mail_address)

ssh: ssh-config test-gce.pem
	ssh -F ssh-config test-gce.asia-east1-c.gcp-eval

ssh-with-gcloud: ssh-config test-gce.pem
	gcloud compute ssh test-gce

ssh-config test-gce.pem:
	gcloud compute config-ssh --ssh-config-file ssh-config --ssh-key-file test-gce.pem

options=-var cidr_home="`curl -s http://ipecho.net/plain`/32"

plan:
	terraform plan $(options) 

apply:
	terraform apply $(options)

distclean:
	rm -f ssh-config test-gce.pem test-gce.pem.pub

###
ansible: .e/bin/ansible
.e/bin/ansible: .e/bin/pip
	.e/bin/pip install ansible==1.9.5
.e/bin/pip:
	virtualenv .e
