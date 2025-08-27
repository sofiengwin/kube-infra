<service-name>.<namespace>.svc.cluster.local:<service-port>
loki.monitoring.svc.cluster.local:3100
prometheus-server.monitoring.svc.cluster.local:80

    kubectl exec -it loki-0   -- /bin/bash
    kubectl exec -it pod/grafana-b4c8fb764-gpv5x  -n monitoring   -- /bin/bash

