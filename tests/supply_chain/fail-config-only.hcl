# FAIL case: compliant plan, but the configuration uses an unapproved provider
# range, a look-alike provider and unpinned or untrusted modules.
mock "tfplan/v2" {
  module {
    source = "../../testdata/mock-tfplan-v2-pass.sentinel"
  }
}

mock "tfconfig/v2" {
  module {
    source = "../../testdata/mock-tfconfig-v2-fail.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
