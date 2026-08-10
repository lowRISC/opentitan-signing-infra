# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//signing:util.bzl", "KeySetInfo", "key_from_dict")
load("//toolchains/opentitantool:opentitantool.bzl", "OPENTITANTOOL_TOOLCHAIN")

# Note: RSA keys are not used and as such are not supported in signature tests;
# support for RSA keys will be dropped in the future.

def _signature_test_impl(ctx):
    keys = []
    opentitantool = ctx.toolchains[OPENTITANTOOL_TOOLCHAIN].tools.executable
    script = ctx.actions.declare_file("{}.bash".format(ctx.label.name))
    verify_args = ""
    ecdsa_key = key_from_dict(ctx.attr.ecdsa_key, "ecdsa_key")
    spx_key = key_from_dict(ctx.attr.spx_key, "spx_key")

    selected_ecdsa_key_path = ""
    selected_spx_key_path = ""

    if ctx.attr.spx_domain != "":
        verify_args = "--spx --domain " + ctx.attr.spx_domain
    if ecdsa_key:
        selected_ecdsa_key_path = ecdsa_key.file.short_path
        keys.append(ecdsa_key.file)
    if spx_key:
        selected_spx_key_path = spx_key.file.short_path
        keys.append(spx_key.file)

    files = [f.short_path for f in ctx.files.srcs]
    ctx.actions.expand_template(
        template = ctx.file._script,
        output = script,
        substitutions = {
            "@FILES@": " ".join(files),
            "@OPENTITANTOOL@": opentitantool.short_path,
            "@VERIFY_ARGS@": verify_args,
            "@ECDSA_KEY@": selected_ecdsa_key_path,
            "@SPX_KEY@": selected_spx_key_path,
            "@IS_NEGATIVE_TEST@": str(ctx.attr.negative_test),
        },
        is_executable = True,
    )

    return [
        DefaultInfo(
            runfiles = ctx.runfiles(files = ctx.files.srcs + keys + [opentitantool]),
            executable = script,
        ),
    ]

signature_test = rule(
    implementation = _signature_test_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, doc = "Signed binary sources"),
        "ecdsa_key": attr.label_keyed_string_dict(
            providers = [[KeySetInfo], [DefaultInfo]],
            allow_files = True,
            doc = "ECDSA public key to validate this image",
        ),
        "spx_key": attr.label_keyed_string_dict(
            providers = [[KeySetInfo], [DefaultInfo]],
            allow_files = True,
            doc = "SPX public key to validate this image",
        ),
        "negative_test": attr.bool(
            default = False,
            doc = "Whether this is a negative test case.",
        ),
        "spx_domain": attr.string(
            default = "",
            values = ["", "Pure", "PrehashedSha256"],
            doc = "The SPHINCS+ domain to use for signing.",
        ),
        "_script": attr.label(
            default = "//signing:signature_test.template.sh",
            doc = "The shell script to execute for the test.",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
    toolchains = [
        OPENTITANTOOL_TOOLCHAIN,
    ],
    test = True,
)
