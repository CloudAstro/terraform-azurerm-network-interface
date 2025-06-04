locals {
  nics_diagnostic_settings = var.diagnostic_settings != null ? {
    for ra in flatten([
      for ck, iface in var.interfaces : [
        for rk, rv in var.diagnostic_settings : {
          interface_name          = iface.name
          diagnostic_settings_key = rk
          diagnostic_settings     = rv
        }
      ]
    ]) : "${ra.interface_name}-${ra.diagnostic_settings_key}" => ra
  } : {}
}
