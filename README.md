<service-name>.<namespace>.svc.cluster.local:<service-port>
loki.monitoring.svc.cluster.local:3100
prometheus-server.monitoring.svc.cluster.local:80

    kubectl exec -it loki-0   -- /bin/bash
    kubectl exec -it pod/grafana-564bdc978f-wnvtx  -n monitoring   -- /bin/bash
prometheus-server.monitoring.svc.cluster.local:80/api/datasources/uid/:uid/resources/*

http://prometheus-server.monitoring.svc.cluster.local:80/explore?orgId=1&panes={"m6o":{"datasource":"dew8a9xi1r5z4e","queries":[{"refId":"A","expr":"sum(rate([$__rate_interval]))+/+sum(rate([$__rate_interval]))","range":true,"datasource":{"type":"prometheus","uid":"dew8a9xi1r5z4e"},"editorMode":"code","legendFormat":"__auto"}],"range":{"from":"now-2d","to":"now"}}}&schemaVersion=1

curl http:/loki.monitoring.svc.cluster.local:3100/config
curl http:/loki.monitoring.svc.cluster.local:3100/loki/api/v1/index/volume
curl http:/loki.godwinogbara.com/loki/api/v1/index/volume_range


GET /loki/api/v1/index/volume
GET /loki/api/v1/index/volume_range


// discovery.kubernetes allows you to find scrape targets from Kubernetes resources.
// It watches cluster state and ensures targets are continually synced with what is currently running in your cluster.
discovery.kubernetes "pod" {
  role = "pod"
}

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
  //rule {
  //  source_labels = ["__meta_kubernetes_pod_name"]
  //  action = "replace"
  //  target_label = "pod"
  //}


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

  // Label creation - "container" field from "__meta_kubernetes_pod_uid" and "__meta_kubernetes_pod_container_name"
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
        cluster = "<CLUSTER_NAME>",
      }
  }

  forward_to = [loki.write.<WRITE_COMPONENT_NAME>.receiver]
}
