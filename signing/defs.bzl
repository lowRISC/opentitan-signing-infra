# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//signing:keyset.bzl", _keyset = "keyset")
load(
    "//signing:signing.bzl",
    _sign_bin = "sign_bin",
    _sign_binary = "sign_binary",
)
load("//signing:test.bzl", _signature_test = "signature_test")
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

# Re-export rules for offline signing
offline_presigning_artifacts = _offline_presigning_artifacts
offline_fake_ecdsa_sign = _offline_fake_ecdsa_sign
offline_fake_rsa_sign = _offline_fake_rsa_sign
offline_signature_attach = _offline_signature_attach

#Re-export rules for testing signing operations
signature_test = _signature_test
