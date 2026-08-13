# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

hsm = module_extension(
    implementation = lambda _: _hsm_repos(),
)

def _hsm_repos():
    http_archive(
        name = "softhsm2",
        build_file = Label("//third_party/hsm:BUILD.softhsm2.bazel"),
        url = "https://github.com/softhsm/SoftHSMv2/archive/22b1487449ae3075ae36a98706e4eeff43a6d147.tar.gz",
        strip_prefix = "SoftHSMv2-22b1487449ae3075ae36a98706e4eeff43a6d147",
        sha256 = "958acfc96b10bdd5f01f48fb6249b72884e2141b2139c3110c5f5a964ed635f3",
        patches = [
            Label("//third_party/hsm/patches:0001-Disable-filename-logging.patch"),
            Label("//third_party/hsm/patches:0002-Implement-SLH-DSA.patch"),
        ],
        patch_args = ["-p1"],
    )
