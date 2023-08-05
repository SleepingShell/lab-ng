#!/bin/bash
#Parts of this taken from billimek/k8s-gitops
#source ./environment.sh
source ./.env

echo "installing fluxv2"
flux check --pre > /dev/null
FLUX_PRE=$?
if [ $FLUX_PRE != 0 ]; then 
  echo -e "flux prereqs not met:\n"
  flux check --pre
  exit 1
fi
if [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN is not set! Check $REPO_ROOT/setup/.env"
  exit 1
fi

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=lab-ng \
  --branch main \
  --path=kubernetes \
  --personal

FLUX_INSTALLED=$?
if [ $FLUX_INSTALLED != 0 ]; then 
  echo -e "flux did not install correctly, aborting!"
  exit 1
fi

FLUX_READY=1
while [ $FLUX_READY != 0 ]; do
  echo "waiting for flux pod to be fully ready..."
  kubectl -n flux-system wait --for condition=available deployment/source-controller
  FLUX_READY="$?"
  sleep 5
done

# SEALED_SECRETS_READY=1
# while [ $SEALED_SECRETS_READY != 0 ]; do
#   echo "waiting for sealed secrets pod to be fully ready..."
#   kubectl -n sealed-secrets wait --for condition=available deployment/sealed-secrets
#   SEALED_SECRETS_READY="$?"
#   sleep 5
# done

# echo "Grabbing sealed-secrets public key and writing"
# kubeseal --controller-name sealed-secrets --fetch-cert > pub-cert.pem

# ./bootstrap-secrets.sh