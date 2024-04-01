WORKPLACE = infra

init:
		terraform -chdir=$(WORKPLACE) init

plan: init
		terraform -chdir=$(WORKPLACE) plan \
			-input=false \
			-out=tf.plan

apply: init
		cd $(WORKPLACE) && \
		terraform apply \
			-input=false \
			-auto-approve=true \
			tf.plan

destroy: init
		cd $(WORKPLACE) && \
		terraform destroy \
			-input=false \
			-auto-approve=true
