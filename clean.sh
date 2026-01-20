!#/bin/bash

# set -e
# app_name=$1
# echo $app_name

# # Delete the ArgoCD Application resource with cascade deletion
# kubectl delete app $app_name -n argocd --cascade=foreground

# # If the application is stuck in deletion due to finalizers, remove them:
# kubectl patch app $app_name -n argocd -p '{"metadata":{"finalizers":[]}}' --type=merge

# # Then force delete the application
# kubectl delete app $app_name -n argocd --force --grace-period=0

# kubectl get app -n argocd


# #!/bin/bash

set -e
app_name=$1
echo "Attempting to delete application: $app_name"

# First, try to patch the application to remove finalizers
echo "Removing finalizers..."
kubectl patch app $app_name -n argocd -p '{"metadata":{"finalizers":[]}}' --type=merge 2>/dev/null || true

# Delete any resources managed by the application first (if they exist)
echo "Cleaning up managed resources in target namespace..."
namespace=$(kubectl get app $app_name -n argocd -o jsonpath='{.spec.destination.namespace}' 2>/dev/null || echo "")
if [ ! -z "$namespace" ]; then
  echo "Target namespace: $namespace"
  # Optional: force delete all resources in the namespace created by this app
  # kubectl delete all --all -n $namespace --force --grace-period=0 2>/dev/null || true
fi

# Force delete the application with grace period 0
echo "Force deleting ArgoCD application..."
kubectl delete app $app_name -n argocd --force --grace-period=0 2>/dev/null || true

# If still exists, try cascade=orphan to abandon resources
echo "Attempting deletion with cascade=orphan..."
kubectl delete app $app_name -n argocd --cascade=orphan 2>/dev/null || true

# Final check and force removal from etcd if needed
if kubectl get app $app_name -n argocd &>/dev/null; then
  echo "Application still exists, removing finalizers again and force deleting..."
  kubectl patch app $app_name -n argocd -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete app $app_name -n argocd --force --grace-period=0
fi

echo "Cleanup complete. Remaining applications:"
kubectl get app -n argocd