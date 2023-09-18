resource "kubectl_manifest" "nodejs-app" {
  yaml_body = file("${path.module}/K8s/deployment.yml")
}


resource "kubectl_manifest" "nodejs-app-service" {
  yaml_body = file("${path.module}/K8s/service.yml")
}
 