#!/bin/bash

# Pre-checks
if [[ -z "$DOMAIN" ]]; then
    echo "You must provide DOMAIN environment variable!" 1>&2
    exit 1
fi
if [[ -z "$GD_Key" ]]; then
    echo "You must provide GD_Key environment variable!" 1>&2
    exit 1
fi
if [[ -z "$GD_Secret" ]]; then
    echo "You must provide GD_Secret environment variable!" 1>&2
    exit 1
fi
if [[ -z "$DNS_FUNC" ]]; then
    echo "You must provide DNS_FUNC environment variable!" 1>&2
    exit 1
fi

# Defining vars
export SECRET_NAME="wildcard-$DOMAIN"
export EXISTING_NAMESPACES=$(kubectl --kubeconfig /data/config get ns)

# Actual logic for requesting letsencrypt cert
cd /root/.acme.sh
./acme.sh -d "$DOMAIN" -d "*.$DOMAIN" --issue --dns $DNS_FUNC \
    --yes-I-know-dns-manual-mode-enough-go-ahead-please	
cd "/root/.acme.sh/$DOMAIN"

# Convert cert to pem format because tls secret needs this format
openssl x509 -in "$DOMAIN.cer" -out "$DOMAIN.pem"

# Deleting previous and creating new secret on default namespace
kubectl --kubeconfig /data/config delete secret "$SECRET_NAME"
kubectl --kubeconfig /data/config create secret tls "$SECRET_NAME" --key="$DOMAIN.key" --cert="$DOMAIN.pem"

if [ $ADDITIONAL_NAMESPACES = "all" ]; then
  # Deleting previous and creating new secret on ALL namespaces
  for N in $(kubectl get ns -o name)
  do
    NAMESPACE=$(echo $N | sed 's/^\(namespace\/\)*//')
    kubectl --kubeconfig /data/config -n $NAMESPACE delete secret "$SECRET_NAME"
    kubectl --kubeconfig /data/config -n $NAMESPACE create secret tls "$SECRET_NAME" --key="$DOMAIN.key" --cert="$DOMAIN.pem"
  done
else
  # Deleting previous and creating new secret on additionally defined namespaces, conditioning each namespace if that exist
  for NAMESPACE in $ADDITIONAL_NAMESPACES
  do
  if echo "$EXISTING_NAMESPACES" | grep -q "$NAMESPACE"; then
      kubectl --kubeconfig /data/config -n $NAMESPACE delete secret "$SECRET_NAME"
      kubectl --kubeconfig /data/config -n $NAMESPACE create secret tls "$SECRET_NAME" --key="$DOMAIN.key" --cert="$DOMAIN.pem"
  else
      echo "WARN: $NAMESPACE namespace doesn't exist, therefore $SECRET_NAME secret can't be applied there!"
  fi
done
fi