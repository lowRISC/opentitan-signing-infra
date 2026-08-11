#!/usr/bin/env bash
#
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

ACTUAL_FILE="$1"
EXPECTED_FILE="$2"

cmp -l "$ACTUAL_FILE" "$EXPECTED_FILE"
