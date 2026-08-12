// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use hsmtool::module::Module;

#[test]
/// A smoketest that we can use hsmlib when integrated downstream,
fn hsmlib_smoke() {
    // We expect initialization to fail given that we haven't set up
    // the environment correctly, but we should test that we can at
    // least call into this function.
    assert!(Module::initialize("dummy").is_err());
}
