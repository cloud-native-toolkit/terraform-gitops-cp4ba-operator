locals {
  name          = "cp4ba-operator"
  subscription_name= "ibm-cp4a-operator"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  yaml_dir_pvc      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}-pvc"
  service_url   = "http://${local.name}.${var.namespace}"
  subscription_chart_dir = "${path.module}/chart/cp4ba-operator"
  #chart_dir = "${path.module}/chart/ibm-cp4ba-operator"

  values_content = {
    "cp4ba" = {        
          namespace = var.namespace
          channel             = var.channel
          source              = var.catalog
          sourceNamespace     = var.catalog_namespace
          }

    values_file = "values-${var.server_name}.yaml"   
  }
   

  layer = "services"
  type  = "base"
  application_branch = "main" 
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {  
  
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.subscription_chart_dir}' '${local.namespace}'  '${local.yaml_dir}'"
    #command = "${path.module}/scripts/create-yaml.sh '${local.name}'"
    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
      
    }   
  }
}

resource null_resource setup_gitops {
  
  #depends_on = [null_resource.setup_gitops_wait_pvc,null_resource.setup_gitops_pvc,null_resource.create_yaml]
  depends_on = [null_resource.create_yaml]
  triggers = {
    name = local.name
    namespace = var.namespace 
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}
  

  ### This the modified for operator pvc creation
resource null_resource create_pvc_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-pvc-yaml.sh '${local.name}' '${local.yaml_dir_pvc}' '${var.storageclass_operator}' '${var.namespace}'" 

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource null_resource setup_gitops_pvc {
  #depends_on = [null_resource.create_pvc_yaml,null_resource.setup_gitops_pvc]
  depends_on = [null_resource.create_pvc_yaml]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.yaml_dir_pvc
    server_name = var.server_name
    layer = "infrastructure"
    #layer = "services"
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' "
    
    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' "

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}



#### To wait until pvc is ready
/*
resource null_resource wait_pvc_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/wait_until_pvc_bound.sh '${var.namespace}'" 

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource null_resource setup_gitops_wait_pvc {
  #depends_on = [null_resource.wait_pvc_yaml,null_resource.setup_gitops_pvc]
  depends_on = [null_resource.wait_pvc_yaml]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.yaml_dir_pvc
    server_name = var.server_name
    layer = "infrastructure"
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' "
    
    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' "

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}
*/