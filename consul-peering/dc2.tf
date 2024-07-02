resource "consul_config_entry" "dc2_mesh" {
  provider = consul.dc2
  name      = "mesh"
  kind      = "mesh"
  partition = "default"

  config_json = jsonencode({
    peering = {
        peerThroughMeshGateways = true
    }
  })
}

resource "consul_config_entry" "dc2_proxy_defaults" {
  provider = consul.dc2
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

resource "consul_peering" "dc1-dc2" {
  provider = consul.dc2

  peer_name     = var.dc2_peername
  peering_token = consul_peering_token.dc1-dc2.peering_token

}
