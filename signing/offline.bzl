# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//signing:framing.bzl", "post_signing_attach", "presigning_artifacts")
load(
    "//signing:util.bzl",
    "KeySetInfo",
    "PreSigningBinaryInfo",
    "key_from_dict",
    "local_sign",
    "local_spx_sign",
    "signing_tool_info",
)
load("//toolchains/opentitantool:opentitantool.bzl", "OPENTITANTOOL_TOOLCHAIN")

def _offline_presigning_artifacts(ctx):
    opentitantool = ctx.toolchains[OPENTITANTOOL_TOOLCHAIN].tools.executable
    ecdsa_key = key_from_dict(ctx.attr.ecdsa_key, "ecdsa_key")
    rsa_key = key_from_dict(ctx.attr.rsa_key, "rsa_key")
    spx_key = key_from_dict(ctx.attr.spx_key, "spx_key")
    digests = []
    bins = []
    script = []
    for src in ctx.files.srcs:
        artifacts = presigning_artifacts(
            ctx,
            opentitantool,
            src,
            ctx.attr.manifest,
            ecdsa_key,
            rsa_key,
            spx_key,
        )
        bins.append(artifacts.pre)
        digests.append(artifacts.digest)
        script.extend(artifacts.script)
        if artifacts.spxmsg:
            digests.append(artifacts.spxmsg)

    default_files = digests
    if script:
        script_file = ctx.actions.declare_file("{}.json".format(ctx.attr.name))
        ctx.actions.write(script_file, json.encode_indent(script, indent = "  ") + "\n")
        default_files.append(script_file)

    return [
        DefaultInfo(files = depset(default_files), data_runfiles = ctx.runfiles(files = default_files)),
        PreSigningBinaryInfo(files = depset(bins)),
        OutputGroupInfo(digest = depset(digests), binary = depset(bins), script = depset([script_file])),
    ]

offline_presigning_artifacts = rule(
    implementation = _offline_presigning_artifacts,
    attrs = {
        "srcs": attr.label_list(allow_files = True, doc = "Binary files to generate digests for"),
        "manifest": attr.label(allow_single_file = True, doc = "Manifest for this image"),
        "ecdsa_key": attr.label_keyed_string_dict(
            providers = [[KeySetInfo], [DefaultInfo]],
            allow_files = True,
            doc = "ECDSA public key to validate this image",
        ),
        "rsa_key": attr.label_keyed_string_dict(
            providers = [[KeySetInfo], [DefaultInfo]],
            allow_files = True,
            doc = "RSA public key to validate this image",
        ),
        "spx_key": attr.label_keyed_string_dict(
            providers = [[KeySetInfo], [DefaultInfo]],
            allow_files = True,
            doc = "SPX public key to validate this image",
        ),
    },
    toolchains = [
        OPENTITANTOOL_TOOLCHAIN,
    ],
)

def _offline_fake_rsa_sign(ctx):
    opentitantool = ctx.toolchains[OPENTITANTOOL_TOOLCHAIN].tools.executable
    outputs = []
    rsa_key = key_from_dict(ctx.attr.rsa_key, "rsa_key")
    tool, _, _ = signing_tool_info(ctx, ctx.attr.rsa_key, opentitantool)
    for file in ctx.files.srcs:
        # Skip the presigning script.
        if file.basename.endswith(".json"):
            continue

        # Skip any SPHINCS+ messages if we're using the `Pure` domain instead of the `PreHashedSha256` domain
        if file.basename.endswith(".spx-message"):
            continue
        _, sig, _ = local_sign(ctx, tool, file, None, rsa_key)
        outputs.append(sig)
    return [DefaultInfo(files = depset(outputs), data_runfiles = ctx.runfiles(files = outputs))]

offline_fake_rsa_sign = rule(
    implementation = _offline_fake_rsa_sign,
    attrs = {
        "srcs": attr.label_list(allow_files = True, doc = "Digest files to sign"),
        "rsa_key": attr.label_keyed_string_dict(
            allow_files = True,
            mandatory = True,
            doc = "RSA private key to sign this image",
        ),
    },
    toolchains = [
        OPENTITANTOOL_TOOLCHAIN,
    ],
    doc = "Create detached signatures using on-disk private keys via opentitantool.",
)

def _offline_fake_ecdsa_sign(ctx):
    opentitantool = ctx.toolchains[OPENTITANTOOL_TOOLCHAIN].tools.executable
    outputs = []
    ecdsa_key = key_from_dict(ctx.attr.ecdsa_key, "ecdsa_key")
    tool, _, _ = signing_tool_info(ctx, ctx.attr.ecdsa_key, opentitantool)
    for file in ctx.files.srcs:
        # Skip the presigning script.
        if file.basename.endswith(".json"):
            continue

        # Skip any SPHINCS+ messages if we're using the `Pure` domain instead of the `PreHashedSha256` domain
        if file.basename.endswith(".spx-message"):
            continue
        sig, _, _ = local_sign(ctx, tool, file, ecdsa_key, None)
        outputs.append(sig)
    return [DefaultInfo(files = depset(outputs), data_runfiles = ctx.runfiles(files = outputs))]

offline_fake_ecdsa_sign = rule(
    implementation = _offline_fake_ecdsa_sign,
    attrs = {
        "srcs": attr.label_list(allow_files = True, doc = "Digest files to sign"),
        "ecdsa_key": attr.label_keyed_string_dict(
            allow_files = True,
            mandatory = True,
            doc = "ECDSA private key to sign this image",
        ),
    },
    toolchains = [
        OPENTITANTOOL_TOOLCHAIN,
    ],
    doc = "Create detached signatures using on-disk private keys via opentitantool.",
)

def _offline_fake_spx_sign(ctx):
    opentitantool = ctx.toolchains[OPENTITANTOOL_TOOLCHAIN].tools.executable
    outputs = []
    spx_key = key_from_dict(ctx.attr.spx_key, "spx_key")
    spx_domain = spx_key.config.get("domain", "Pure")
    expected_input_ext = ".digest" if spx_domain.lower() == "prehashedsha256" else ".spx-message"
    tool, _, _ = signing_tool_info(ctx, ctx.attr.spx_key, opentitantool)
    files = {}
    for file in ctx.files.srcs:
        # Skip the presigning script.
        if file.basename.endswith(".json"):
            continue
        if file.basename.endswith(expected_input_ext):
            spx_sig = local_spx_sign(ctx, tool, file, spx_key)
            outputs.append(spx_sig)
    if not outputs:
        fail("No SPHINCS+ messages found for SPX signing")

    return [DefaultInfo(files = depset(outputs), data_runfiles = ctx.runfiles(files = outputs))]

offline_fake_spx_sign = rule(
    implementation = _offline_fake_spx_sign,
    attrs = {
        "srcs": attr.label_list(allow_files = True, doc = "Digest files to sign"),
        "spx_key": attr.label_keyed_string_dict(
            allow_files = True,
            mandatory = True,
            doc = "SPHINCS+ private key to sign this image",
        ),
    },
    toolchains = [
        OPENTITANTOOL_TOOLCHAIN,
    ],
    doc = "Create detached signatures using on-disk private keys via opentitantool.",
)

def _offline_signature_attach(ctx):
    if ctx.files.rsa_signatures and ctx.files.ecdsa_signatures:
        fail("Only one of RSA or ECDSA signatures should be provided")

    opentitantool = ctx.toolchains[OPENTITANTOOL_TOOLCHAIN].tools.executable
    inputs = {}
    for src in ctx.attr.srcs:
        if PreSigningBinaryInfo in src:
            for file in src[PreSigningBinaryInfo].files.to_list():
                f, _ = paths.split_extension(file.basename)
                inputs[f] = {"bin": file}
        elif DefaultInfo in src:
            for file in src[DefaultInfo].files.to_list():
                f, _ = paths.split_extension(file.basename)
                inputs[f] = {"bin": file}
    for sig in ctx.files.rsa_signatures:
        f, _ = paths.split_extension(sig.basename)
        if f not in inputs:
            fail("RSA signature {} does not have a corresponding entry in srcs".format(sig.path))
        inputs[f]["rsa_sig"] = sig
    for sig in ctx.files.ecdsa_signatures:
        f, _ = paths.split_extension(sig.basename)
        if f not in inputs:
            fail("ECDSA signature {} does not have a corresponding entry in srcs".format(sig.path))
        inputs[f]["ecdsa_sig"] = sig
    for sig in ctx.files.spx_signatures:
        f, _ = paths.split_extension(sig.basename)
        if f not in inputs:
            fail("SPX signature {} does not have a corresponding entry in srcs".format(sig.path))
        inputs[f]["spx_sig"] = sig

    outputs = []
    for f in inputs:
        if inputs[f].get("bin") == None:
            print("WARNING: No pre-signed binary for", f)
            continue
        if inputs[f].get("rsa_sig") == None and inputs[f].get("ecdsa_sig") == None:
            print("WARNING: No RSA or ECDSA signature file for", f)
            continue
        out = post_signing_attach(
            ctx,
            opentitantool,
            inputs[f]["bin"],
            inputs[f].get("ecdsa_sig"),
            inputs[f].get("rsa_sig"),
            inputs[f].get("spx_sig"),
        )
        outputs.append(out)
    return [DefaultInfo(files = depset(outputs), data_runfiles = ctx.runfiles(files = outputs))]

offline_signature_attach = rule(
    implementation = _offline_signature_attach,
    attrs = {
        "srcs": attr.label_list(allow_files = True, providers = [[PreSigningBinaryInfo], [DefaultInfo]], doc = "Binary files to sign"),
        "ecdsa_signatures": attr.label_list(allow_files = True, doc = "ECDSA signed digest files"),
        "rsa_signatures": attr.label_list(allow_files = True, doc = "RSA signed digest files"),
        "spx_signatures": attr.label_list(allow_files = True, doc = "SPX+ signed digest files"),
    },
    toolchains = [
        OPENTITANTOOL_TOOLCHAIN,
    ],
)
