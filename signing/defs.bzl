# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//signing:keyset.bzl", _keyset = "keyset")
load(
    "//signing:signing.bzl",
    _sign_bin = "sign_bin",
    _sign_binary = "sign_binary",
)
load("//signing:tool.bzl", _signing_tool = "signing_tool")
load(
    "//signing:util.bzl",
    _KeySetInfo = "KeySetInfo",
    _SigningToolInfo = "SigningToolInfo",
)

# Re-export providers to allow other rules to use them
SigningToolInfo = _SigningToolInfo
KeySetInfo = _KeySetInfo

# Re-export rules for defining keysets, describing signing tools & cfgs, and signing binaries
keyset = _keyset
signing_tool = _signing_tool
sign_bin = _sign_bin
sign_binary = _sign_binary
