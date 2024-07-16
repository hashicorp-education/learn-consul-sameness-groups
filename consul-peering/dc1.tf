resource "consul_config_entry" "dc1_mesh" {
  provider = consul.dc1
  name      = "mesh"
  kind      = "mesh"
  partition = "default"

  config_json = jsonencode({
    peering = {
        peerThroughMeshGateways = true
    }
  })
}

resource "consul_config_entry" "dc1_proxy_defaults" {
  provider = consul.dc1
  kind = "proxy-defaults"
  # Note that only "global" is currently supported for proxy-defaults and that
  # Consul will override this attribute if you set it to anything else.
  name = "global"

  config_json = jsonencode({
    meshGateway = {
      mode = "local"
    }
  })
}

resource "consul_peering_token" "dc1-dc2" {
  provider  = consul.dc1
  peer_name = var.dc1_peername
}
