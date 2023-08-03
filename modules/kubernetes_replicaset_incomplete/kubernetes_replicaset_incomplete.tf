resource "shoreline_notebook" "kubernetes_replicaset_incomplete" {
  name       = "kubernetes_replicaset_incomplete"
  data       = file("${path.module}/data/kubernetes_replicaset_incomplete.json")
  depends_on = [shoreline_action.invoke_resource_allocation_check,shoreline_action.invoke_replicaset_check,shoreline_action.invoke_scale_deployment]
}

resource "shoreline_file" "resource_allocation_check" {
  name             = "resource_allocation_check"
  input_file       = "${path.module}/data/resource_allocation_check.sh"
  md5              = filemd5("${path.module}/data/resource_allocation_check.sh")
  description      = "Insufficient resources in the cluster, such as insufficient memory or CPU, can cause pods to fail to initialize or start."
  destination_path = "/agent/scripts/resource_allocation_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "replicaset_check" {
  name             = "replicaset_check"
  input_file       = "${path.module}/data/replicaset_check.sh"
  md5              = filemd5("${path.module}/data/replicaset_check.sh")
  description      = "Incorrect configuration of the Kubernetes Replicaset and its associated pods can cause the desired number of pods to be different from the actual number of running pods."
  destination_path = "/agent/scripts/replicaset_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "scale_deployment" {
  name             = "scale_deployment"
  input_file       = "${path.module}/data/scale_deployment.sh"
  md5              = filemd5("${path.module}/data/scale_deployment.sh")
  description      = "Adjusts the number of replicas in a deployment."
  destination_path = "/agent/scripts/scale_deployment.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_resource_allocation_check" {
  name        = "invoke_resource_allocation_check"
  description = "Insufficient resources in the cluster, such as insufficient memory or CPU, can cause pods to fail to initialize or start."
  command     = "`chmod +x /agent/scripts/resource_allocation_check.sh && /agent/scripts/resource_allocation_check.sh`"
  params      = []
  file_deps   = ["resource_allocation_check"]
  enabled     = true
  depends_on  = [shoreline_file.resource_allocation_check]
}

resource "shoreline_action" "invoke_replicaset_check" {
  name        = "invoke_replicaset_check"
  description = "Incorrect configuration of the Kubernetes Replicaset and its associated pods can cause the desired number of pods to be different from the actual number of running pods."
  command     = "`chmod +x /agent/scripts/replicaset_check.sh && /agent/scripts/replicaset_check.sh`"
  params      = ["REPLICA_SET_NAME"]
  file_deps   = ["replicaset_check"]
  enabled     = true
  depends_on  = [shoreline_file.replicaset_check]
}

resource "shoreline_action" "invoke_scale_deployment" {
  name        = "invoke_scale_deployment"
  description = "Adjusts the number of replicas in a deployment."
  command     = "`chmod +x /agent/scripts/scale_deployment.sh && /agent/scripts/scale_deployment.sh`"
  params      = ["DEPLOYMENT_NAME"]
  file_deps   = ["scale_deployment"]
  enabled     = true
  depends_on  = [shoreline_file.scale_deployment]
}

