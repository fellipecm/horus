output "cloud_init" {
  value = templatefile(
    "${path.module}/cloud-init.yaml.tpl",
    {
      k3s_config = base64encode(templatefile(
        "${path.module}/k3s-${var.role}-config.yaml.tpl",
        {
          role           = var.role
          server_address = var.server_address
          token          = var.token
        }
      )),
      k3s_service = base64encode(templatefile(
        "${path.module}/k3s.service.tpl",
        {
          role = var.role
        }
      ))
    }
  )
  sensitive = true
}
