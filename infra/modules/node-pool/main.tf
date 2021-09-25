data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "image" {
  compartment_id           = var.compartment_id
  operating_system         = var.image.operating_system
  operating_system_version = var.image.version
  shape                    = var.shape.name
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance_configuration" "node_pool" {
  compartment_id = var.compartment_id
  display_name   = "k3s-${var.role}"
  freeform_tags  = var.tags

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = var.compartment_id

      create_vnic_details {
        assign_public_ip = false
        hostname_label   = "k3s-${var.role}"
        # nsg_ids          = [var.nsg_id]
        subnet_id = var.subnet_id
      }

      extended_metadata = {
        subnet_id = var.subnet_id
      }

      metadata = {
        ssh_authorized_keys = var.ssh_public_key
        user_data = base64encode(templatefile(
          "${path.module}/user-data/cloud-init.yaml.tpl",
          {
            k3s_config = base64encode(templatefile(
              "${path.module}/user-data/k3s-config.yaml.tpl",
              {
                role  = var.role
                token = var.token
              }
            )),
            k3s_service = base64encode(templatefile(
              "${path.module}/user-data/k3s.service.tpl",
              {
                role = var.role
              }
            ))
          }
        ))
      }

      shape = var.shape.name
      source_details {
        source_type = "image"
        image_id    = data.oci_core_images.image.images[0].id
      }

      dynamic "shape_config" {
        for_each = length(var.shape.config) > 0 ? [1] : []
        content {
          ocpus         = tonumber(lookup(var.shape.config, "cpus", 0))
          memory_in_gbs = tonumber(lookup(var.shape.config, "memory", 0))
        }
      }
    }
  }
}

resource "oci_core_instance_pool" "node_pool" {
  compartment_id            = var.compartment_id
  display_name              = "k3s-${var.role}s"
  instance_configuration_id = oci_core_instance_configuration.node_pool.id
  size                      = var.size

  placement_configurations {
    availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains[0].name
    primary_subnet_id   = var.subnet_id
  }

  # TODO
  # timeouts {
  #   create = "3m"
  # }
}
