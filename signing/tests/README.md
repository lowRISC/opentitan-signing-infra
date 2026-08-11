[//]: # (Copyright lowRISC contributors \(OpenTitan project\).)
[//]: # (Licensed under the Apache License, Version 2.0, see LICENSE for details.)
[//]: # (SPDX-License-Identifier: Apache-2.0)

# Signing Rule Tests

To test the implementation of the signing rules, we perform key (manifest) integrity checks and signature verification against existing signed binaries, to ensure that there have been no regressions.
This requires some signed artifacts to be checked in, where these artifacts may differ depending on the version of OpenTitanTool that was used to produce them.
As such, these artifacts may need to be updated across devbundle release bumps to keep these tests passing.

To generate these artifacts, you can follow the below steps.
These steps still worked as of commit [`0135da5e167491a7709d972789278acd2f4cec4e`](https://github.com/lowRISC/opentitan/commit/0135da5e167491a7709d972789278acd2f4cec4e) on `OpenTitan/earlgrey_1.0.0`.

1. Checkout the OpenTitan commit from which the devbundle release was made.

2. Configure the path to your signing repo:
   ```sh
   export SIGNING_REPO_PATH=/path/to/your/signing/repo
   ```

3. Modify the `//sw/device/silicon_creator/rom_ext:rom_ext_{}_slot_{}` targets to use the fake `ecdsa_keyset` and `spx_keyset` under `//sw/device/silicon_creator/lib/ownership/keys/fake` instead of the the fake ROM keys.
   Change the selected key to be `app_prod_0` in both instances.
   This is needed because the devbundle only exports the fake ownership keys for FPGA development. 
   **TODO: determine if there is a better solution - perhaps export more fake keys in the devbundle?**

4. Build the ROM_EXT targets with
   ```sh
   bazelisk build //sw/device/silicon_creator/rom_ext:rom_ext_dice_x509_slot_a.
   ```

5. Copy across and replace the existing signed binaries
   ```sh
   cp -fv bazel-bin/sw/device/silicon_creator/rom_ext/rom_ext_dice_x509_slot_a_*.app_prod_0.app_prod_0.signed.bin $SIGNING_REPO_PATH/signing/tests
   ```

6. Build a Bazel target with a corrupted signature:
   ```sh
   bazelisk build //sw/device/silicon_creator/rom/e2e:empty_test_slot_a_corrupted_fpga_cw310_rom_with_fake_keys.prod_key_0.signed.bin
   ```

7. Copy across and replace the existing corrupted binary:
   ```sh
   cp -fv bazel-bin/sw/device/silicon_creator/rom/e2e/empty_test_slot_a_corrupted_fpga_cw310_rom_with_fake_keys.prod_key_0.signed.bin $SIGNING_REPO_PATH/signing/tests
   ```

8.  Verify that everything still works by running
   ```sh
   bazelisk test //signing/tests/...
   ```
   If it doesn't, either re-follow the process or fix the breakage in these tests targets.

**TODO: consider converting to a script to generate these artifacts automatically.**

Note that RSA signing is untested as it is intended to be deprecated in the near future.
