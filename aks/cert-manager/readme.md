# Cert Manager for Let'sEncrypt ACME

### Installing cert manager on K8S
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade cert-manager jetstack/cert-manager \
    --install \
    --create-namespace \
    --wait \
    --namespace cert-manager \
    --set installCRDs=true
```

### Create managed identity for cert-manager in azure and grant required permissions
```
export DOMAIN_NAME=
export AZURE_RESOURCE_GROUP=

export IDENTITY_NAME=cert-manager
az identity create --name "${IDENTITY_NAME}" --resource-group "${AZURE_RESOURCE_GROUP}"

export IDENTITY_CLIENT_ID=$(az identity show --name "${IDENTITY_NAME}" --query 'clientId' -o tsv --resource-group "${AZURE_RESOURCE_GROUP}")
az role assignment create \
    --role "DNS Zone Contributor" \
    --assignee $IDENTITY_CLIENT_ID \
    --scope "subscriptions/5ecbf67e-8d4c-4945-b3dc-ca0ea1cfdb12/resourceGroups/k8_group/providers/Microsoft.Network/dnszones/k8s.devopsdani.com"
```

### Install the Azure workload identity features
```
az extension add --name aks-preview
az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"

# It takes a few minutes. Verify with following:
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/EnableWorkloadIdentityPreview')].{Name:name,State:properties.state}"

# When ready:
az provider register --namespace Microsoft.ContainerService
```

### Reconfigure the cluster
```
az aks update \
    --name ${CLUSTER} --resource-group "${AZURE_RESOURCE_GROUP}" \
    --enable-oidc-issuer \
    --enable-workload-identity
```

### Reconfigure cert-manager
```
helm upgrade cert-manager jetstack/cert-manager --namespace cert-manager --reuse-values --values values.yaml
```

### Add federated identity 
```
export CLUSTER=


export SERVICE_ACCOUNT_NAME=cert-manager
export SERVICE_ACCOUNT_NAMESPACE=cert-manager
az aks update -g $AZURE_RESOURCE_GROUP -n $CLUSTER --enable-oidc-issuer # OPTIONAL
export SERVICE_ACCOUNT_ISSUER=$(az aks show --resource-group $AZURE_RESOURCE_GROUP --name $CLUSTER --query "oidcIssuerProfile.issuerUrl" -o tsv)
az identity federated-credential create \
  --name "cert-manager" \
  --identity-name "${IDENTITY_NAME}" \
  --issuer "${SERVICE_ACCOUNT_ISSUER}" \
  --resource-group $AZURE_RESOURCE_GROUP \
  --subject "system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}"
```

### Deploy cluster issuer

```
export EMAIL_ADDRESS=
export AZURE_ZONE_NAME=
export AZURE_SUBSCRIPTION=
export AZURE_SUBSCRIPTION_ID=

envsubst < clusterissuer-letsencrypt.yaml | kubectl apply -f -
```

### Setup TLS secret replication

```
kubectl apply -f certificate.yaml
```