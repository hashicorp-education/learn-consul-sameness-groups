data "kubectl_path_documents" "hashicups_manifests" {
  pattern = "${path.module}/../hashicups-v1.0.2/*.yaml"
}

resource "kubectl_manifest" "hashicups" {
  for_each   = toset(data.kubectl_path_documents.hashicups_manifests.documents)
  yaml_body  = each.value
  depends_on = [helm_release.consul]
}
