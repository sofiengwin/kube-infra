<service-name>.<namespace>.svc.cluster.local:<service-port>
loki.monitoring.svc.cluster.local:3100
prometheus-server.monitoring.svc.cluster.local:80

kubectl patch deployment argocd-server -n argocd --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["argocd-server", "--insecure"]}]'

for crd in $(kubectl get crd | grep argoproj.io | awk '{print $1}'); do
  kubectl patch crd $crd -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete crd $crd --ignore-not-found
done

## Force cleanup
### List all ArgoCD applications
kubectl get app -n argocd

# Force delete a specific application with finalizer removal

kubectl patch app alloy -n prometheus -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl delete app alloy -n prometheus --force --grace-period=0




              // discovery.relabel rewrites the label set of the input targets by applying one or more relabeling rules.
              // If no rules are defined, then the input targets are exported as-is.
              discovery.relabel "pod_logs" {
                targets = discovery.kubernetes.pod.targets

                // Label creation - "namespace" field from "__meta_kubernetes_namespace"
                rule {
                  source_labels = ["__meta_kubernetes_namespace"]
                  action = "replace"
                  target_label = "namespace"
                }

                // Label creation - "pod" field from "__meta_kubernetes_pod_name"
                rule {
                  source_labels = ["__meta_kubernetes_pod_name"]
                  action = "replace"
                  target_label = "pod"
                }

                // Label creation - "container" field from "__meta_kubernetes_pod_container_name"
                rule {
                  source_labels = ["__meta_kubernetes_pod_container_name"]
                  action = "replace"
                  target_label = "container"
                }

                // Label creation -  "app" field from "__meta_kubernetes_pod_label_app_kubernetes_io_name"
                rule {
                  source_labels = ["__meta_kubernetes_pod_label_app_kubernetes_io_name"]
                  action = "replace"
                  target_label = "app"
                }

                // Label creation -  "job" field from "__meta_kubernetes_namespace" and "__meta_kubernetes_pod_container_name"
                // Concatenate values __meta_kubernetes_namespace/__meta_kubernetes_pod_container_name
                rule {
                  source_labels = ["__meta_kubernetes_namespace", "__meta_kubernetes_pod_container_name"]
                  action = "replace"
                  target_label = "job"
                  separator = "/"
                  replacement = "$1"
                }

                // Label creation - "__path__" field from "__meta_kubernetes_pod_uid" and "__meta_kubernetes_pod_container_name"
                // Concatenate values __meta_kubernetes_pod_uid/__meta_kubernetes_pod_container_name.log
                rule {
                  source_labels = ["__meta_kubernetes_pod_uid", "__meta_kubernetes_pod_container_name"]
                  action = "replace"
                  target_label = "__path__"
                  separator = "/"
                  replacement = "/var/log/pods/*$1/*.log"
                }

                // Label creation -  "container_runtime" field from "__meta_kubernetes_pod_container_id"
                rule {
                  source_labels = ["__meta_kubernetes_pod_container_id"]
                  action = "replace"
                  target_label = "container_runtime"
                  regex = "^(\\S+):\\/\\/.+$"
                  replacement = "$1"
                }
              }

              // loki.source.kubernetes tails logs from Kubernetes containers using the Kubernetes API.
              loki.source.kubernetes "pod_logs" {
                targets    = discovery.relabel.pod_logs.output
                forward_to = [loki.process.pod_logs.receiver]
              }

              // loki.process receives log entries from other Loki components, applies one or more processing stages,
              // and forwards the results to the list of receivers in the component's arguments.
              loki.process "pod_logs" {
                stage.static_labels {
                    values = {
                      cluster = "kube-infra",
                    }
                }

                forward_to = [loki.write.default.receiver]
              }

              // local.file_match discovers files on the local filesystem using glob patterns and the doublestar library. It returns an array of file paths.
              local.file_match "node_logs" {
                path_targets = [{
                    // Monitor syslog to scrape node-logs
                    __path__  = "/var/log/syslog",
                    job       = "node/syslog",
                    node_name = sys.env("HOSTNAME"),
                    cluster   = "kube-infra",
                }]
              }

              // loki.source.file reads log entries from files and forwards them to other loki.* components.
              // You can specify multiple loki.source.file components by giving them different labels.
              loki.source.file "node_logs" {
                targets    = local.file_match.node_logs.targets
                forward_to = [loki.write.default.receiver]
              }


              loki.write "default" {
                endpoint {
                  url = "http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push"
                }







{
  "model": "gpt-oss",
  "messages": [{"role": "user", "content": "Tell me about Canada."}],
  "stream": false,
  "format": {
    "type": "object",
    "properties": {
      "name": {"type": "string"},
      "capital": {"type": "string"},
      "languages": {
        "type": "array",
        "items": {"type": "string"}
      }
    },
    "required": ["name", "capital", "languages"]
  }
}



	__meta_kubernetes_pod_container_name                           = "solidqueue",
	__meta_kubernetes_pod_controller_kind                          = "ReplicaSet",
	__meta_kubernetes_pod_controller_name                          = "fiq-solidqueue-58755d7c8b",
	__meta_kubernetes_pod_host_ip                                  = "192.168.1.211",
	__meta_kubernetes_pod_ip                                       = "10.42.5.15",
	__meta_kubernetes_pod_label_app_kubernetes_io_component        = "solidqueue",
	__meta_kubernetes_pod_label_app_kubernetes_io_instance         = "fiq",
	__meta_kubernetes_pod_label_app_kubernetes_io_name             = "fiq",
	__meta_kubernetes_pod_label_pod_template_hash                  = "58755d7c8b",
	__meta_kubernetes_pod_labelpresent_app_kubernetes_io_component = "true",
	__meta_kubernetes_pod_labelpresent_app_kubernetes_io_instance  = "true",
	__meta_kubernetes_pod_labelpresent_app_kubernetes_io_name      = "true",
	__meta_kubernetes_pod_labelpresent_pod_template_hash           = "true",
	__meta_kubernetes_pod_name                                     = "fiq-solidqueue-58755d7c8b-fjdz8",
	__meta_kubernetes_pod_node_name                                = "pve-worker-2",