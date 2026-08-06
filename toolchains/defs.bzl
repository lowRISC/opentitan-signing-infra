# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

"""Toolchain / Tooling rule definitions.
"""

def _host_tool_transition_impl(settings, attr):
    """Defines the transition for building host tools, passing through all build settings
    specified on the command line.
    """

    return {
        "//command_line_option:platforms": "@local_config_platform//:host",
        "//command_line_option:copt": settings["//command_line_option:copt"],
        "//command_line_option:features": settings["//command_line_option:features"],
    }

host_tool_transition = transition(
    implementation = _host_tool_transition_impl,
    inputs = [
        "//command_line_option:copt",
        "//command_line_option:features",
    ],
    outputs = [
        "//command_line_option:platforms",
        "//command_line_option:copt",
        "//command_line_option:features",
    ],
)
