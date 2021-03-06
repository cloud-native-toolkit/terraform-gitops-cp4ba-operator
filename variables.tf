
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
  sensitive   = true
}

variable "namespace" {
  type        = string
  #default = "gitops-cp-cp4ba-operator"
  description = "The namespace where the application should be deployed" 
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}
variable "channel" {
  type        = string
  description = "The channel that should be used to deploy the operator"
  default     = "v21.3"
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
variable "storageclass_operator" {
  type        = string
  #default="cp4a-file-retain-gold-gid"
  #default="ibmc-vpc-block-metro-retain-10iops-tier"
  default="portworx-db2-rwx-sc"
  description = "The storge class for operator pvc"
}
