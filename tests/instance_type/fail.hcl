# FAIL case: the non-compliant mocks break instance_type, so main must be false.
# The policy's print output (run with -verbose) lists each violation it found.
mock "tfplan/v2" {
  module {
    source = "../../testdata/mock-tfplan-v2-fail.sentinel"
  }
}

mock "tfconfig/v2" {
  module {
    source = "../../testdata/mock-tfconfig-v2-pass.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
