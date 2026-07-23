# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@rules_rust//rust:defs.bzl", "rust_binary", "rust_doc", "rust_library", "rust_test")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "doc_files",
    srcs = glob(["**/*.md"]),
)

alias(
    name = "binding_srcs",
    actual = "@rust_opentitan_signing_crates//:cryptoki-sys-binding-srcs",
)

py_binary(
    name = "pkcs11_consts",
    srcs = ["scripts/pkcs11_consts.py"],
)

genrule(
    name = "object_class",
    srcs = [":binding_srcs"],
    outs = ["object_class.rs"],
    cmd = """
        $(execpath :pkcs11_consts) \
            --binding $(locations :binding_srcs) \
            --serde --strum --conv_data CKO cryptoki::object::ObjectClass > $@
    """,
    tools = [
        ":pkcs11_consts",
    ],
)

genrule(
    name = "key_type",
    srcs = [":binding_srcs"],
    outs = ["key_type.rs"],
    cmd = """
        $(execpath :pkcs11_consts) \
            --binding $(locations :binding_srcs) \
            --serde --strum --conv_data CKK cryptoki::object::KeyType > $@
    """,
    tools = [
        ":pkcs11_consts",
    ],
)

genrule(
    name = "certificate_type",
    srcs = [":binding_srcs"],
    outs = ["certificate_type.rs"],
    cmd = """
        $(execpath :pkcs11_consts) \
            --binding $(locations :binding_srcs) \
            --serde --strum --conv_data CKC cryptoki::object::CertificateType > $@
    """,
    tools = [
        ":pkcs11_consts",
    ],
)

genrule(
    name = "mechanism_type",
    srcs = [":binding_srcs"],
    outs = ["mechanism_type.rs"],
    cmd = """
        $(execpath :pkcs11_consts) \
            --binding $(locations :binding_srcs) \
            --serde --strum --conv_data CKM cryptoki::mechanism::MechanismType > $@
    """,
    tools = [
        ":pkcs11_consts",
    ],
)

genrule(
    name = "attribute_type",
    srcs = [":binding_srcs"],
    outs = ["attribute_type.rs"],
    cmd = """
        $(execpath :pkcs11_consts) \
            --binding $(locations :binding_srcs) \
            --serde --strum CKA cryptoki::object::AttributeType > $@
    """,
    tools = [
        ":pkcs11_consts",
    ],
)

rust_library(
    name = "hsmlib",
    srcs = [
        "src/commands/aes/export.rs",
        "src/commands/aes/generate.rs",
        "src/commands/aes/import.rs",
        "src/commands/aes/mod.rs",
        "src/commands/ecdsa/export.rs",
        "src/commands/ecdsa/generate.rs",
        "src/commands/ecdsa/import.rs",
        "src/commands/ecdsa/mod.rs",
        "src/commands/ecdsa/sign.rs",
        "src/commands/ecdsa/verify.rs",
        "src/commands/exec.rs",
        "src/commands/kdf/export.rs",
        "src/commands/kdf/generate.rs",
        "src/commands/kdf/import.rs",
        "src/commands/kdf/mod.rs",
        "src/commands/mldsa/export.rs",
        "src/commands/mldsa/export_csr.rs",
        "src/commands/mldsa/generate.rs",
        "src/commands/mldsa/import.rs",
        "src/commands/mldsa/mod.rs",
        "src/commands/mldsa/sign.rs",
        "src/commands/mldsa/verify.rs",
        "src/commands/mod.rs",
        "src/commands/object/destroy.rs",
        "src/commands/object/list.rs",
        "src/commands/object/mod.rs",
        "src/commands/object/read.rs",
        "src/commands/object/show.rs",
        "src/commands/object/update.rs",
        "src/commands/object/write.rs",
        "src/commands/rsa/decrypt.rs",
        "src/commands/rsa/encrypt.rs",
        "src/commands/rsa/export.rs",
        "src/commands/rsa/generate.rs",
        "src/commands/rsa/import.rs",
        "src/commands/rsa/mod.rs",
        "src/commands/rsa/sign.rs",
        "src/commands/rsa/verify.rs",
        "src/commands/spx/export.rs",
        "src/commands/spx/generate.rs",
        "src/commands/spx/import.rs",
        "src/commands/spx/list.rs",
        "src/commands/spx/mod.rs",
        "src/commands/spx/sign.rs",
        "src/commands/spx/verify.rs",
        "src/commands/token.rs",
        "src/error.rs",
        "src/extra/mod.rs",
        "src/extra/spxef.rs",
        "src/extra/spxkms.rs",
        "src/lib.rs",
        "src/module.rs",
        "src/profile.rs",
        "src/util/attribute/attr.rs",
        "src/util/attribute/data.rs",
        "src/util/attribute/date.rs",
        "src/util/attribute/error.rs",
        "src/util/attribute/mod.rs",
        "src/util/ef.rs",
        "src/util/escape.rs",
        "src/util/helper.rs",
        "src/util/key/ecdsa.rs",
        "src/util/key/mldsa.rs",
        "src/util/key/mod.rs",
        "src/util/key/rsa.rs",
        "src/util/mod.rs",
        "src/util/secret.rs",
        "src/util/signing.rs",
        "src/util/wrap.rs",
    ],
    compile_data = [
        ":attribute_type",
        ":certificate_type",
        ":key_type",
        ":mechanism_type",
        ":object_class",
    ],
    crate_name = "hsmtool",
    rustc_env = {
        "ATTRIBUTE_TYPE": "$(location :attribute_type)",
        "CERTIFICATE_TYPE": "$(location :certificate_type)",
        "KEY_TYPE": "$(location :key_type)",
        "MECHANISM_TYPE": "$(location :mechanism_type)",
        "OBJECT_CLASS": "$(location :object_class)",
    },
    deps = [
        "//hsmtool/acorn",
        "//hsmtool/sphincsplus",
        "@lowrisc_serde_annotate//serde_annotate",
        "@rust_opentitan_signing_crates//:anyhow",
        "@rust_opentitan_signing_crates//:base64ct",
        "@rust_opentitan_signing_crates//:clap",
        "@rust_opentitan_signing_crates//:const-oid",
        "@rust_opentitan_signing_crates//:cryptoki",
        "@rust_opentitan_signing_crates//:cryptoki-sys",
        "@rust_opentitan_signing_crates//:der",
        "@rust_opentitan_signing_crates//:directories",
        "@rust_opentitan_signing_crates//:ecdsa",
        "@rust_opentitan_signing_crates//:erased-serde",
        "@rust_opentitan_signing_crates//:hex",
        "@rust_opentitan_signing_crates//:indexmap",
        "@rust_opentitan_signing_crates//:log",
        "@rust_opentitan_signing_crates//:ml-dsa",
        "@rust_opentitan_signing_crates//:once_cell",
        "@rust_opentitan_signing_crates//:p256",
        "@rust_opentitan_signing_crates//:pem-rfc7468",
        "@rust_opentitan_signing_crates//:pkcs8",
        "@rust_opentitan_signing_crates//:rand",
        "@rust_opentitan_signing_crates//:regex",
        "@rust_opentitan_signing_crates//:reqwest",
        "@rust_opentitan_signing_crates//:rsa",
        "@rust_opentitan_signing_crates//:rustix",
        "@rust_opentitan_signing_crates//:serde",
        "@rust_opentitan_signing_crates//:serde_bytes",
        "@rust_opentitan_signing_crates//:serde_json",
        "@rust_opentitan_signing_crates//:sha2",
        "@rust_opentitan_signing_crates//:signature",
        "@rust_opentitan_signing_crates//:spki",
        "@rust_opentitan_signing_crates//:strum",
        "@rust_opentitan_signing_crates//:thiserror",
        "@rust_opentitan_signing_crates//:typetag",
        "@rust_opentitan_signing_crates//:x509-cert",
        "@rust_opentitan_signing_crates//:zeroize",
    ],
)

rust_binary(
    name = "hsmtool",
    srcs = ["src/hsmtool.rs"],
    deps = [
        ":hsmlib",
        "@rust_opentitan_signing_crates//:anyhow",
        "@rust_opentitan_signing_crates//:clap",
        "@rust_opentitan_signing_crates//:cryptoki",
        "@rust_opentitan_signing_crates//:env_logger",
        "@rust_opentitan_signing_crates//:log",
    ],
)

rust_test(
    name = "hsmlib_test",
    crate = ":hsmlib",
    data = glob([
        "testdata/**",
    ]),
    env = {
        "TESTDATA": "$(rootpath testdata/key/test1_pkcs1.der)",
    },
)

rust_doc(
    name = "hsmlib_doc",
    crate = ":hsmlib",
)
