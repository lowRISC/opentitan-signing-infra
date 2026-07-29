# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

"""Provides the non-hermetic `HOME` variable from the environment for use in signing tools.

The home directory is currently used by hsmtool to access the user's Google Could credentials
for signing flows. We restrict non-hermetic exposure to just this variable, in an effort to
expose the least amount of environment information to Bazel rules as possible - to help
improve reproducibility and cacheability of builds/tests.
"""

def _nonhermetic_repo_impl(rctx):
    env = "    \"HOME\": \"{}\",".format(rctx.os.environ.get(v, ""))
    rctx.file("env.bzl", "ENV = {{\n{}\n}}\n".format(env))
    rctx.file("BUILD.bazel", "exports_files(glob([\"**\"]))\n")

nonhermetic_repo = repository_rule(
    implementation = _nonhermetic_repo_impl,
    attrs = {},
    environ = NONHERMETIC_ENV_VARS,
)
