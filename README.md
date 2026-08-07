[//]: # (Copyright lowRISC contributors \(OpenTitan project\).)
[//]: # (Licensed under the Apache License, Version 2.0, see LICENSE for details.)
[//]: # (SPDX-License-Identifier: Apache-2.0)

# OpenTitan Signing Infrastructure

## About this repository

This repository contains the signing infrastructure for the [OpenTitan project](https://github.com/lowRISC/opentitan/).
This includes `hsmtool`, a Hardware Security Module (HSM) tool used to generate & manage keys that are installed into OpenTitan devices during manufacturing.
It also includes the Bazel rules related to signing binaries for use with OpenTitan.

Though this repo can be used stand-alone, it is intended to be consumed by downstream OpenTitan and other OpenTitan projects as a [Bzlmod](https://docs.bazel.build/versions/5.1.0/bzlmod.html) dependency.
OpenTitan is administered by [lowRISC CIC](https://www.lowrisc.org) as a collaborative project to produce high quality, open IP for instantiation as a full-featured product.
See the [OpenTitan site](https://opentitan.org) and [OpenTitan docs](https://opentitan.org/book/) for more information about the project.

## Getting started

For local development, most required tooling is packaged by [Bazel](https://bazel.build/).
The recommended development flow is to install [Bazelisk](https://github.com/bazelbuild/bazelisk), which will automatically manage bazel versions for you.

Currently, the only system dependencies needed for local development are dependencies of the pre-built LLVM toolchain, including `glibc` and `libxml2`.
If you do not already have these, you can explicitly install the required system dependencies with:
```sh
sudo apt update && sudo apt install -y libxml2 build-essential
```

There are also some small Python scripts under `scripts/` which are used for CI workflows.
If you wish to run these locally, you will need to source `python3` along with its `git` library.
These Python dependencies are **not** required to build or run the signing infrastructure.

You can then build all targets with:

```sh
bazelisk build //...
```

You can run all tests with:

```sh
bazelisk test //...
```

To run formatters for local development, you can run:
```sh
bazelisk run format
```

## Downstream usage

### Rust Bindgen Toolchain

Compiling `hsmtool` requires a bindgen toolchain, which upstream `rules_rust` will default to building from source.
For local development, we instead prefer to use a prebuilt LLVM toolchain to help drastically reduce build times - but this is only as a development dependency.

Downstream consumers will thus need to ensure that they register a Rust Bindgen toolchain via `register_toolchains`.
To instead use the default toolchain (i.e. build LLVM from source), you can simply add the following to your `MODULE.bazel` file:

```python
register_toolchains("@rules_rust_bindgen//:default_bindgen_toolchain")
```

### OpenTitanTool Toolchain

The signing rules use [`opentitantool`](https://github.com/lowRISC/opentitan/blob/master/sw/host/opentitantool/README.md) to perform some of their framing operations.
By default, this is pulled in from the OpenTitan release devbundle, which is a development dependency.
Hence, you will need to register an `opentitantool` toolchain in your downstream project.

For example, you might create a `toolchains/BUILD.bazel` file containing:

```python
load("@opentitan_signing_infra//toolchains/opentitantool:opentitantool.bzl", "opentitantool")

package(default_visibility = ["//visibility:public"])

opentitantool(
    name = "custom_opentitantool",
    # Change this part to point to your opentitantool
    tool = "//path/to/your/custom:opentitantool",
)

toolchain(
    name = "custom_opentitantool_toolchain",
    toolchain = ":custom_opentitantool",
    toolchain_type = "@opentitan_signing_infra//toolchains/opentitantool:toolchain_type",
)
```

And then in your `MODULE.bazel`:

```python
register_toolchains("//toolchains:custom_opentitantool_toolchain")
```

## Licensing

Unless otherwise noted, everything in this repository is covered by the Apache License, Version 2.0 (see [LICENSE](LICENSE) for the full text).

## Read more

* [Contribution Guide](CONTRIBUTING.md)
* [Guidance for reporting security vulnerabilities](https://github.com/lowRISC/opentitan/blob/master/SECURITY.md)
* [`hsmtool` Documentation](hsmtool/README.md)
* [Signing Rule Documentation](signing/README.md)
