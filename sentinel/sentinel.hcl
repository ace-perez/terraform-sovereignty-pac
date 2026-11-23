# Intended levels on a paid tier. HCP Free allows only one mandatory policy, so
# these six are bundled into hcp/atul_guardrails.sentinel instead (see README).

policy "sovereignty" {
  source            = "./sovereignty.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "supply_chain" {
  source            = "./supply_chain.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "encryption" {
  source            = "./encryption.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "metadata" {
  source            = "./metadata.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "network" {
  source            = "./network.sentinel"
  enforcement_level = "hard-mandatory"
}

# Cost control, not a legal one, so it can be overridden.
policy "instance_type" {
  source            = "./instance_type.sentinel"
  enforcement_level = "soft-mandatory"
}
