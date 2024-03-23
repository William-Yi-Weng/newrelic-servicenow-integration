#!/bin/bash
set -e

if [[ $# != 1 ]]; then
  echo "Usage $(basename "${0}") <plan|apply|destroy>"
  exit 1
fi

rm -rf .terraform

OPT=$1

terraform init \
  -backend=true \
  -reconfigure \
  infra/

case $OPT in
plan)
    terraform plan \
        -lock=false \
        -input=false \
        -out=tf.plan \
        infra/
  ;;
apply)
    terraform apply \
        -input=false \
        -auto-approve=true \
        -lock=true \
        tf.plan
  ;;
destroy)
    terraform destroy \
        -input=false \
        -auto-approve=true \
        -lock=true \
        tf.plan
  ;;
*)
  die 102 "Unknown OPERATION: $OPT"
  ;;
esac
