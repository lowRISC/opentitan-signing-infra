# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//signing:keyset.bzl", _keyset = "keyset")
load(
    "//signing:offline.bzl",
    _offline_fake_ecdsa_sign = "offline_fake_ecdsa_sign",
    _offline_fake_rsa_sign = "offline_fake_rsa_sign",
    _offline_presigning_artifacts = "offline_presigning_artifacts",
    _offline_signature_attach = "offline_signature_attach",
)
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
    _PreSigningBinaryInfo = "PreSigningBinaryInfo",
    _SigningToolInfo = "SigningToolInfo",
    _key_from_dict = "key_from_dict",
)

# Re-export providers to allow other rules to use them
PreSigningBinaryInfo = _PreSigningBinaryInfo
SigningToolInfo = _SigningToolInfo
KeySetInfo = _KeySetInfo

# Re-export rules for defining keysets, describing signing tools & cfgs, and signing binaries
keyset = _keyset
key_from_dict = _key_from_dict
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
