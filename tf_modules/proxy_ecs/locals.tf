locals {
  # convert list into map keyed on name, as for_each requires map type
  # ignore any list objects where name contains non-alpha-numeric-hyphen chars
  port_mappings_map   = {
    for pm in var.proxy_config.port_mappings: 
    pm.name => pm
    if can(regex("^[0-9A-Za-z-]+$", pm.name)) 
  }

  # number of port_mappings rules
  pm_len            = length(var.proxy_config.port_mappings)

  # number of groups of 5 (each ecs_service supports only upto 5 elb target groups)
  port_mappings_group_count   = ceil(local.pm_len / 5)

  # slice port_mappings into list of maps of upto 5 rules each
  port_mappings_group_map  = [ 
    for i in range(local.port_mappings_group_count): { 
        for pm in slice(var.proxy_config.port_mappings, i*5, (i+1)*5 > local.pm_len ? local.pm_len : (i+1)*5): 
          pm.name => pm
          if can(regex("^[0-9A-Za-z-]+$", pm.name))
      }
    ]

  haproxy_config        = templatefile("${path.module}/haproxy.cfg.tpl", {
    port_mappings       = local.port_mappings_map
  })

  port_mappings_task_def_json = jsonencode([
    for pm in var.proxy_config.port_mappings: { 
      containerPort = pm.proxy_port, 
      hostPort = pm.proxy_port,
      protocol = "tcp"
    }
  ])

  /*
  pm                = var.proxy_config.port_mappings

  pm_len            = length(local.pm)

  pm_groups_count   = ceil(local.pm_len / 5)

  pm_groups         = [ for i in range(local.pm_groups_count): 
                    zipmap(
                      slice(keys(local.pm), i*5, (i+1)*5 > local.pm_len ? local.pm_len : (i+1)*5), 
                      slice(values(local.pm), i*5, (i+1)*5 > local.pm_len ? local.pm_len : (i+1)*5)
                    ) 
                ]
  */
}

