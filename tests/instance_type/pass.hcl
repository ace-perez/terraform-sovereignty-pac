# PASS case: the compliant plan and configuration must satisfy instance_type.
mock "tfplan/v2" {
  module {
    source = "../../testdata/mock-tfplan-v2-pass.sentinel"
  }
}

mock "tfconfig/v2" {
  module {
    source = "../../testdata/mock-tfconfig-v2-pass.sentinel"
  }
}

test {
  rules = {
    main = true
  }
}
