# Install

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
    --create-namespace \
    --namespace nginx-ingress \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux \
    --set publishService.enabled=true \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=***REMOVED***

kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission # Run anyways, no problem if resource is not found
```