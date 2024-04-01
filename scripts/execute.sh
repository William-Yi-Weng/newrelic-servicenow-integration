#!/bin/bash
set -e

if [[ $# != 1 ]]; then
  echo "Usage $(basename "${0}") <plan|apply|destroy>"
  exit 1
fi

rm -rf .terraform

OPT=$1

terraform -chdir=infra/ init \
  -reconfigure \
  -upgrade \
  -backend=false
  

case $OPT in
plan)
    terraform -chdir=infra/ plan \
        -lock=false \
        -input=false \
        -out=tf.plan
  ;;
apply)
    terraform apply \
        -input=false \
        -auto-approve=true \
        -lock=false \
        ./infra/tf.plan
  ;;
destroy)
    terraform destroy \
        -input=false \
        -auto-approve=true \
        -lock=false \
        ./infra/tf.plan
  ;;
*)
  die 102 "Unknown OPERATION: $OPT"
  ;;
esac
