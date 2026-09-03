# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

"""OpenTitanTool toolchain configuration.

Defines a provider and rule for an OpenTitanTool toolchain, where the opentitantool
executable is used in signing rule implementations for signing framing operations and
for offline signing, as well as to test hsmtool for local development & CI.
"""

OPENTITANTOOL_TOOLCHAIN = "@opentitan_signing_infra//toolchains/opentitantool:toolchain_type"

OpenTitanToolInfo = provider(
    fields = ["executable"],
)

def _opentitantool_impl(ctx):
    """Defines the OpenTitanTool toolchain, which is just a single executable 'tool'."""
    return platform_common.ToolchainInfo(
        name = ctx.label.name,
        tools = OpenTitanToolInfo(
            executable = ctx.file.tool,
        ),
    )

opentitantool = rule(
    implementation = _opentitantool_impl,
    attrs = {
        "tool": attr.label(
            allow_single_file = True,
            mandatory = True,
            executable = True,
            cfg = "exec",
        ),
    },
    doc = "Toolchain for opentitantool, used in signing rules",
    provides = [platform_common.ToolchainInfo],
)
