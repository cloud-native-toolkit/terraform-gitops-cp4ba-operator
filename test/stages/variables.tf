
# Resource Group Variables
variable "resource_group_name" {
  type        = string
  description = "Existing resource group where the IKS cluster will be provisioned."
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The api key for IBM Cloud access"
}

variable "server_url" {
  type        = string
}

variable "bootstrap_prefix" {
  type = string
  default = ""
}

variable "namespace" {
  type        = string
  default = "cp4ba"
  description = "Namespace for tools"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = ""
}

variable "cluster_type" {
  type        = string
  description = "The type of cluster that should be created (openshift or kubernetes)"
}

variable "cluster_exists" {
  type        = string
  description = "Flag indicating if the cluster already exists (true or false)"
  default     = "true"
}

variable "name_prefix" {
  type        = string
  description = "Prefix name that should be used for the cluster and services. If not provided then resource_group_name will be used"
  default     = ""
}

variable "vpc_cluster" {
  type        = bool
  description = "Flag indicating that this is a vpc cluster"
  default     = false
}

variable "git_token" {
  type        = string
  description = "Git token"
}

variable "git_host" {
  type        = string
  default     = "github.com"
}

variable "git_type" {
  default = "github"
}

variable "git_org" {
  default = "cloud-native-toolkit-test"
}

variable "git_repo" {
  default = "git-module-test"
}

variable "gitops_namespace" {
  default = "openshift-gitops"
}

variable "git_username" {
}

variable "kubeseal_namespace" {
  default = "sealed-secrets"
}

variable "cp_entitlement_key" {
}

variable "channel" {
  type        = string
  description = "The channel that should be used to deploy the operator"
  default     = "v21.1"
}
variable "catalog" {
  type        = string
  description = "The catalog source that should be used to deploy the operator"
  default     = "ibm-operator-catalog"
}
variable "catalog_namespace" {
  type        = string
  description = "The namespace where the catalog has been deployed"
  default     = "openshift-marketplace"
}
variable "docker-username" {
  type        = string
  default="cp"
  description = "docker-username"
}
variable "docker-password" {
  type        = string
  default="eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1ODU4MDgyNDYsImp0aSI6IjkyYmFjY2YxYzAwYTQ1MDBhYTc3OTJmYWE2OTNhMzgzIn0.bTjCyzArfW_e1hoakIO2B6mt12fV3P3FibVz2O1gT3A"
  description = "docker-password"
}
variable "docker-server" {
  type        = string
  default="cp.icr.io"
  description = "docker-server"
}
variable "docker-email" {
  type        = string
  default="dineshchandrapandey@in.ibm.com"
  description = "docker-email"
}
variable "registry_key_name" {
  type        = string
  default="admin.registrykey"
  description = "registry_key_name"  
}