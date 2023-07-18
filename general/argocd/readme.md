### Install
```
helm repo add argo-cd https://argoproj.github.io/argo-helm
helm dep update .
kubectl create ns argocd
helm install -n argocd argo-cd .
```

### Get password
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Set password
Password by default is the same as the pod name: argo-cd-argocd-server-<POD_ID>.
In order to change it, we should use the argocd cli tool, logging in with the initial password and set a new one.
```
kubectl -n argocd exec -it argo-cd-argocd-server-<POD_ID> /bin/bash
> argocd login localhost:8080
> argocd account update-password
```

### Set up ingress auth (optional)

Another layer to supply basic auth password for argocd ingress.

Create new password with the following script:
```
$ htpasswd -c auth foo
New password: <bar>
Re-type new password: <bar>
Adding password for user foo

$ kubectl -n argocd create secret generic admin-auth --from-file=auth
secret "admin-auth" created

$ kubectl -n argocd get secret admin-auth -o yaml
```

```
# admin-auth.yaml
apiVersion: v1
data:
  auth: <auth_key_here>
kind: Secret
metadata:
  name: admin-auth
  namespace: argocd
type: Opaque
```