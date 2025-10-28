<service-name>.<namespace>.svc.cluster.local:<service-port>
loki.monitoring.svc.cluster.local:3100
prometheus-server.monitoring.svc.cluster.local:80

kubectl patch deployment argocd-server -n argocd --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["argocd-server", "--insecure"]}]'

for crd in $(kubectl get crd | grep argoproj.io | awk '{print $1}'); do
  kubectl patch crd $crd -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete crd $crd --ignore-not-found
done
