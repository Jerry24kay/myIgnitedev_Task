resource "kubectl_manifest" "igniteapp" {
  yaml_body = file("${path.module}/ignite_k8s_deployment.yaml")
}

# run this first in terminal: `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm repo update`

resource "helm_release" "kube_prom" {
  name       = "kube-prometheus-stack"
  chart      = "prometheus-community/kube-prometheus-stack"

}