# AKS scripts

## Accessing Private AKS

Add this to your .bashrc:

```
alias k=kubectl

function aksctl() {
    local resource_group="${AKS_RESOURCE_GROUP:-}"
    local cluster_name="${AKS_CLUSTER_NAME:-}"

    if [ -z "$resource_group" ]; then
        echo "Error: AKS_RESOURCE_GROUP environment variable is not set."
        return 1
    fi

    if [ -z "$cluster_name" ]; then
        echo "Error: AKS_CLUSTER_NAME environment variable is not set."
        return 1
    fi

    local command_to_run="kubectl ${@:1}"  # Concatenate all arguments starting from the second one

    local output
    output=$(az aks command invoke --resource-group "$resource_group" --name "$cluster_name" --command "$command_to_run")

    echo "$output" | sed "s/kubectl/aksctl/g"
}

function akshelm() {
    local resource_group="${AKS_RESOURCE_GROUP:-}"
    local cluster_name="${AKS_CLUSTER_NAME:-}"

    if [ -z "$resource_group" ]; then
        echo "Error: AKS_RESOURCE_GROUP environment variable is not set."
        return 1
    fi

    if [ -z "$cluster_name" ]; then
        echo "Error: AKS_CLUSTER_NAME environment variable is not set."
        return 1
    fi

    local command_to_run="helm ${@:1}"  # Concatenate all arguments starting from the second one

    local output
    output=$(az aks command invoke --resource-group "$resource_group" --name "$cluster_name" --command "$command_to_run")

    echo "$output" | sed "s/helm/akshelm/g"
}

function aksexecute() {
    local resource_group="${AKS_RESOURCE_GROUP:-}"
    local cluster_name="${AKS_CLUSTER_NAME:-}"

    if [ -z "$resource_group" ]; then
        echo "Error: AKS_RESOURCE_GROUP environment variable is not set."
        return 1
    fi

    if [ -z "$cluster_name" ]; then
        echo "Error: AKS_CLUSTER_NAME environment variable is not set."
        return 1
    fi

    local command_to_run="${@:1}"  # Concatenate all arguments starting from the second one

    local output
    output=$(az aks command invoke --resource-group "$resource_group" --name "$cluster_name" --command "$command_to_run")

    echo "$output"
}

alias ak=aksctl
alias ah=akshelm
alias ae=aksexecute
AKS_RESOURCE_GROUP=<your_rg>
AKS_CLUSTER_NAME=<your_cluster_name>
```

Example for installing ArgoCD:
```
ae 'helm repo add argo https://argoproj.github.io/argo-helm && helm upgrade -i --create-namespace --set configs.
params."server\.insecure"=true argocd argo/argo-cd -n argocd'
```
