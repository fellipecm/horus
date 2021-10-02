data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_id
}

resource "oci_identity_compartment" "freecloud" {
  compartment_id = data.oci_identity_tenancy.tenancy.id
  name           = var.compartment_name
  description    = var.compartment_description
  freeform_tags  = var.common_tags
}

# TODO The private key generated by this resource will be stored unencrypted in your Terraform state file.
# Generate a private key file outside of Terraform and distribute it securely to the system where Terraform will be run instead.
resource "tls_private_key" "ssh" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/private.pem"
  file_permission = "0600"
}

module "base" {
  source         = "./modules/base"
  compartment_id = oci_identity_compartment.freecloud.id
  tags           = var.common_tags
}

module "kubernetes_cluster" {
  source         = "./modules/kubernetes-cluster"
  compartment_id = oci_identity_compartment.freecloud.id
  server_count   = 1 # TODO multi master with embedded etcd in the same pool
  agent_count    = 2
  ssh_public_key = tls_private_key.ssh.public_key_openssh
  subnet_id      = module.base.subnet_id
  tags           = var.common_tags
}
