# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

"""Signing macros / rules for signing binaries.
"""

load("//signing:framing.bzl", "post_signing_attach", "presigning_artifacts")
load("//signing:util.bzl", "get_override", "key_from_dict", "signing_tool_info")
load("//toolchains/opentitantool:opentitantool.bzl", "OPENTITANTOOL_TOOLCHAIN")

def _clear_if_none_key(key_attr):
    """Clear the key attribute if it is set to "none_key".

    Args:
        key_attr: The key attribute.
    Returns:
        The key attribute if it is not set to "none_key" or {}.
    """
    if not key_attr:
        return None

    key, _ = key_attr.items()[0]

    if key.label.name == "none_key":
        return None

    return key_attr

def sign_binary(ctx, opentitantool, **kwargs):
    """Sign a binary.

    Args:
      ctx: The rule context.
      opentitantool: An opentitantool FilesToRun provider.
      **kwargs: Overrides of values normally retrived from the context object.
        ecdsa_key: The ECDSA signing key.
        rsa_key: The RSA signing key.
        spx_key: The SPHINCS+ signing key.
        bin: The input binary.
        manifest: The manifest header.
    Returns:
        A dict of all of the signing artifacts:
          pre: The pre-signing binary (input binary with manifest changes applied).
          digest: The SHA256 hash over the pre-signing binary.
          spxmsg: The SPHINCS+ message to be signed.
          ecdsa_sig: The ECDSA signature of the digest.
          rsa_sig: The RSA signature of the digest.
          spx_sig: The SPHINCS+ signature over the message.
          signed: The final signed binary.
    """
    key_attr = get_override(ctx, "attr.ecdsa_key", kwargs)
    key_attr = _clear_if_none_key(key_attr)

    ecdsa_key = key_from_dict(key_attr, "ecdsa_key")

    rsa_attr = get_override(ctx, "attr.rsa_key", kwargs)
    rsa_attr = _clear_if_none_key(rsa_attr)

    if rsa_attr and key_attr:
        fail("Only one of ECDSA or RSA key should be provided")

    if rsa_attr:
        # Select RSA as the key attribute since at this point we have already
        # determined that only one of ECDSA or RSA key should be provided.
        key_attr = rsa_attr

    rsa_key = key_from_dict(rsa_attr, "rsa_key")
    spx_key = key_from_dict(get_override(ctx, "attr.spx_key", kwargs), "spx_key")

    manifest = get_override(ctx, "attr.manifest", kwargs)

    artifacts = presigning_artifacts(
        ctx,
        opentitantool,
        get_override(ctx, "file.bin", kwargs),
        manifest,
        ecdsa_key,
        rsa_key,
        spx_key,
        keyname_in_filenames = True,
    )
    tool, signing_func, profile = signing_tool_info(ctx, key_attr, opentitantool)
    ecdsa_sig, rsa_sig, spx_sig = signing_func(
        ctx,
        tool,
        artifacts.digest,
        ecdsa_key,
        rsa_key,
        artifacts.spxmsg,
        spx_key,
        profile,
    )
    signed = post_signing_attach(
        ctx,
        opentitantool,
        artifacts.pre,
        ecdsa_sig,
        rsa_sig,
        spx_sig,
    )
    return {
        "pre": artifacts.pre,
        "digest": artifacts.digest,
        "spxmsg": artifacts.spxmsg,
        "ecdsa_sig": ecdsa_sig,
        "rsa_sig": rsa_sig,
        "spx_sig": spx_sig,
        "signed": signed,
    }

def _sign_bin_impl(ctx):
    opentitantool = ctx.toolchains[OPENTITANTOOL_TOOLCHAIN].tools.executable
    result = sign_binary(ctx, opentitantool)
    return [
        DefaultInfo(files = depset([result["signed"]]), data_runfiles = ctx.runfiles(files = [result["signed"]])),
    ]

sign_bin = rule(
    implementation = _sign_bin_impl,
    attrs = {
        "bin": attr.label(allow_single_file = True),
        "ecdsa_key": attr.label_keyed_string_dict(
            allow_files = True,
            doc = "ECDSA public key to validate this image",
        ),
        "rsa_key": attr.label_keyed_string_dict(
            allow_files = True,
            doc = "RSA public key to validate this image",
        ),
        "spx_key": attr.label_keyed_string_dict(
            allow_files = True,
            doc = "SPX public key to validate this image",
        ),
        "manifest": attr.label(allow_single_file = True, mandatory = True),
    },
    toolchains = [
        OPENTITANTOOL_TOOLCHAIN,
    ],
    doc = "Sign a binary with the specified keys.",
)
