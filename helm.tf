resource "helm_release" "kube-prometheus" {
  name             = "kube-prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "50.1.0"
  namespace        = "monitoring"
  create_namespace = true
}


