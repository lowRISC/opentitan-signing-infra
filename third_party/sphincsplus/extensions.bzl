# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

sphincsplus = module_extension(
    implementation = lambda _: _sphincsplus_repos(),
)

def _sphincsplus_repos(local = None):
    http_archive(
        name = "sphincsplus_fips205_ipd",
        url = "https://github.com/sphincs/sphincsplus/archive/129b72c80e122a22a61f71b5d2b042770890ccee.tar.gz",
        strip_prefix = "sphincsplus-129b72c80e122a22a61f71b5d2b042770890ccee/ref",
        build_file = "@opentitan_signing_infra//third_party/sphincsplus:BUILD.sphincsplus.bazel",
        sha256 = "b301faa7a42ef538323a732929d49341b1cbd8375f643f7d98ca32cd6efacc32",
        patches = [
            Label("@opentitan_signing_infra//third_party/sphincsplus/patches:sphincsplus-namespace.patch"),
        ],
        patch_args = ["-p2"],
    )
