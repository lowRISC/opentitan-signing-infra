[//]: # (Copyright lowRISC contributors \(OpenTitan project\).)
[//]: # (Licensed under the Apache License, Version 2.0, see LICENSE for details.)
[//]: # (SPDX-License-Identifier: Apache-2.0)

# OpenTitan Signing Rules

The OpenTitan signing rules are a collection of Bazel [rules](https://bazel.build/extending/rules) and [macros](https://bazel.build/extending/macros) for signing binaries to run on OpenTitan platforms.

To use these in downstream Bazel projects, you should use the definitions that are exported by [`defs.bzl`](./defs.bzl), e.g.

```python
load("@opentitan_signing_infra//signing:defs.bzl", "sign_binary")
```

## Signing Tools

Signing tools abstract the tooling used for signing operations - for example, using OpenTitanTool to locally sign artifacts, or using `hsmtool` configured with NitroKey or Cloud KMS providers.
The implementation for signing tools can be found in [`tool.bzl`](./tool.bzl).

They can be created with the `signing_tool()` rule, and provide the `SigningToolInfo` provider.
This rule has the following attributes:
* `tool`: A label pointing to the signing tool binary executable to invoke for signing operations.
  This is generally expected to be `opentitantool` for local signing, and `hsmtool` otherwise.
* `data`: A list of labels corresponding to additional files that are needed by the signing tool.
* `env`: A string dictionary, of environment variables that are needed by the signing tool.
* `location`: either `"local"` or `"token"`.
  Local keys are on-disk, and are typically used for simulation or emulation test scenarios.
  Token keys are held in a secure token or HSM, and are typically used for signing artifacts for real chips.

For example, a local & cloud KMS signing configuration might look a bit like the examples below:

```python
load("@opentitan_signing_infra//signing:defs.bzl", "signing_tool")

signing_tool(
    name = "local_signing_tool",
    location = "local",
    tool = "@opentitan_devbundle//:opentitantool/opentitantool",
)

signing_tool(
    name = "cloud_kms_sival",
    data = [
        "pkcs11_cfg.yaml",
        "@cloud_kms_hsm//:libkmsp11",
    ],
    env = {
        "HSMTOOL_MODULE": "$(location @cloud_kms_hsm//:libkmsp11)",
        "KMS_PKCS11_CONFIG": "$(location pkcs11_cfg.yaml)",
    },
    location = "token",
    tool = "@opentitan_signing_infra//hsmtool",
)
```

## Keysets

Key sets abstract information about a set of keys that can be used for signing operations.
The implementation for keysets can be found in [`keyset.bzl`](./keyset.bzl).

Keysets can be created with the `keyset()` rule, and provide the `KeySetInfo` provider.
This rule has the following attributes:
* `keys`: A label-keyed string dict, mapping key files to names.
  When a key file is a public key (whose private component is held in an HSM), the name should be the same as the HSM label of that key.
  Additional key parameters may be specified via colon-separated `key=value` pairs.

  For example, you might have some keys like:
```python
    keys = {
        "app_prod_spx.pem": "app_prod_0",
        "app_dev_spx.pem": "app_dev_0:domain=PreHashedSha256",
    },
```
* `profile`: a string indicating the profile to use.
  If using `hsmtool`, this is the hsmtool profile entry (in `$XDG_CONFIG_HOME/hsmtool/profiles.json`) associated with these keys.
  If using on-disk private keys, this should instead be the special value `local`.
* `tool`: a label for the tool to use.

For example, a fake ECDSA keyset for local OpenTitanTool signing might look like:

```python
load("@opentitan_signing_infra//signing:defs.bzl", "keyset")

keyset(
    name = "ecdsa_keyset",
    build_setting_default = "",
    keys = {
        "test_key_0_ecdsa_p256.der": "test_key_0",
        "dev_key_0_ecdsa_p256.der": "dev_key_0",
        "prod_key_0_ecdsa_p256.der": "prod_key_0",
        "prod_key_1_ecdsa_p256.der": "prod_key_1",
    },
    profile = "local",
    tool = ":local_signing_tool",
)
```

## Signing

The signing operation is **framed** as follows:

1. Before signing we must first generate *pre-signing artifacts*.
   We apply the manifest and the public components of the keys to create a "pre-signing binary" (the input with the manifest changes applied), the digest, and the SPHINCS+ message files.
2. We then create signatures for the binary using the specified signing tool with the aforementioned artifacts.
3. We finally attach any signatures (any ECDSA, RSA or SPHINCS+ signatures returned by the signing tool) to the unsigned binary to produce the signed artifact.

The implementation of the framing operations can be found in [`framing.bzl`](./framing.bzl), whereas the implementation of the signing operation and rule can be found in [`signing.bzl`](./signing.bzl).

`sign_binary()` is a macro that can be used to sign an artifact with some given keys.
As an input, it takes:
* `ctx`: The rule context.
* `opentitantool`: An opentitantool executable `FilesToRunProvider`.
* `**kwargs` Any overrides of values normally retrieved from the context object, which may include:
  * `ecdsa_key`: The ECDSA signing key (string dict).
  * `rsa_key`: The RSA signing key (string dict).
  * `spx_key`: The SPHINCS+ signing key (string dict).
  * `bin`: The input binary to sign.
  * `manifest`: The manifest header.

This in turn then returns a string-keyed dictionary of artifacts, with the following fields:
* `pre`: The pre-signing binary (i.e. the input binary with the manifest changes applied).
* `digest`: The SHA256 hash over the pre-signing binary.
* `spxmsg`: The SPHINCS+ message to be signed.
* `ecdsa_sig`: The ECDSA signature of the digest.
* `rsa_sig`: The RSA signature of the digest.
* `spx_sig`: The SPHINCS+ signature over the message.
* `signed`: The final signed binary.

For use as a standalone rule, the `sign_bin()` rule simply takes the `bin`, `manifest`, `ecdsa_key`, `rsa_key` and/or `spx_key` and will produce a signed binary by taking OpenTitanTool from the toolchain.

## Offline Signing

Often signing operations might need to be completed in "offline" environments, which must be completely disconnected from the rest of the Bazel build process.
As such, mechanisms are provided for producing the pre-signing artifacts and performing the signature attachment for offline signing flows.
The implementation of these rules can be found in [`offline.bzl`](./offline.bzl).

The `offline_presigning_attach()` rule can be used to generate the artifacts to take offline for signing, and provides the `PreSigningBinaryInfo` (and `OutputGroupInfo`) providers.
This rule has the following attributes:
* `srcs`: The artifacts to generate digests for.
* `manifest`: The manifest for this image.
* `ecdsa_key`: The ECDSA signing key (string dict).
* `rsa_key`: The RSA signing key (string dict).
* `spx_key`: The SPHINCS+ signing key (string dict).

After you have performed the offline signature generation, the `offline_signature_attach()` rule then allows you to attach these signatures and generate a signed binary.
This rule has the following attributes:
* `srcs`: The artifacts to sign.
* `ecdsa_signatures`: A list of labels of ECDSA-signed digest files.
* `rsa_signatures`: A list of labels of RSA-signed digest files.
* `spx_signatures`: A list of labels of SPHINCS+-signed message files.

To test these offline signing rules in a complete workflow, the `offline_fake_ecdsa_sign()`,  `offline_fake_rsa_sign()` and `offline_fake_spx_sign()` rules are available.
Each rule takes the list of digest files to sign (`srcs`) and their respective private `rsa_key` / `ecdsa_key` / `spx_key` to sign the image.
This can then be combined with the other offline signing rules to emulate the full offline signing flow without requiring any manual steps.

## Testing

To test these signing rules, the `signature_test()` rule is available, implemented in [`test.bzl`](./test.bzl).
This rule has the following attributes:
* `srcs`: A list of labels for signed binary sources to use for testing.
* `ecdsa_key`: The ECDSA public key to validate the image.
* `spx_key`: The SPHINCS+ public key to validate the image.
* `spx_domain`: Either `""`, `"Pure"`, or `"PrehashedSha256"`.
  This is the SPHINCS+ domain to use for signing.
* `negative_test`: A boolean indicating whether this is a "negative" test case, i.e. we expect signature verification to fail.

Note that as RSA is unused and intended to be deprecated, RSA signing is not supported for this testing flow.
