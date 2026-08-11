# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

"""Rules for describing tools for performing signing operations.
"""

load("//signing:util.bzl", "SigningToolInfo")
load("//toolchains:defs.bzl", "host_tool_transition")

def _signing_tool(ctx):
    env = {k: ctx.expand_location(v, ctx.attr.data) for k, v in ctx.attr.env.items()}
    return [SigningToolInfo(
        tool = ctx.executable.tool,
        data = ctx.files.data,
        env = env,
        location = ctx.attr.location,
    )]

signing_tool = rule(
    implementation = _signing_tool,
    attrs = {
        "tool": attr.label(
            mandatory = True,
            executable = True,
            allow_single_file = True,
            cfg = host_tool_transition,
            doc = "The signing tool binary",
        ),
        "data": attr.label_list(
            allow_files = True,
            cfg = "exec",
            doc = "Additional files needed by the signing tool",
        ),
        "env": attr.string_dict(
            doc = "Environment variables needed by the signing tool",
        ),
        "location": attr.string(
            mandatory = True,
            values = ["local", "token"],
            doc = "The location of private keys.  Local keys are on-disk and are typically used for simulation or emulation (FPGA) test scenarios.  Token keys are held in a secure token or HSM and are typically used for signing artifacts for real chips.",
        ),
    },
    doc = "Create a signing tool, which encapsulates a tool (binary), environment, and private-key location.",
)
