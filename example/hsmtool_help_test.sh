#!/usr/bin/env bash
#
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

HELP_OUTPUT="$("$HSMTOOL" --help 2>&1)"
echo "$HELP_OUTPUT"

grep -q "Usage: hsmtool" <<< "$HELP_OUTPUT"
