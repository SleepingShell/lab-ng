#!/bin/bash
#Parts of this taken from billimek/k8s-gitops
#source ./environment.sh
source .env

echo "Installing Talos Config"
talosctl -n $BIGBOI_IP apply-config --insecure --file ./clusterconfig/cluster-bigboi.yaml
cp ./clusterconfig/talosconfig ~/.talos/config

read -p "Press Enter when install is done, asking for boostrap" </dev/tty
talosctl -n $BIGBOI_IP --talosconfig=./clusterconfig/talosconfig bootstrap

# This seems to not be automatically generating kubeconfig
talosctl -n $BIGBOI_IP kubeconfig

read -p "Press Enter when bootstrap is done" </dev/tty
echo "Installing Cilium"
kubectl kustomize --enable-helm ./cni | kubectl apply -f -

echo "Installing fluxv2"
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