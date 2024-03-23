
build-infra:
	bash scripts/execute.sh plan

deploy-infra:
	bash scripts/execute.sh apply

destroy-infra:
	bash scripts/execute.sh destroy