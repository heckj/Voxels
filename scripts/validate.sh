#!/bin/bash
##===----------------------------------------------------------------------===##
##
## This source file is part of the SwiftNIO open source project
##
## Copyright (c) 2017-2019 Apple Inc. and the SwiftNIO project authors
## Licensed under Apache License v2.0
##
## See LICENSE.txt for license information
## See CONTRIBUTORS.txt for the list of SwiftNIO project authors
##
## SPDX-License-Identifier: Apache-2.0
##
##===----------------------------------------------------------------------===##

SWIFT_FORMAT_VERSION=0.54.6

set -eu
here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

which swiftformat > /dev/null 2>&1 || (echo "swiftformat not installed. You can install it using 'brew install swiftformat'" ; exit -1)

function replace_acceptable_years() {
    # this needs to replace all acceptable forms with 'YEARS'
    sed -e 's/20[12][0-9]-20[12][0-9]/YEARS/' -e 's/20[12][0-9]/YEARS/' -e '/^#!/ d'
}

printf "=> Checking format... "
FIRST_OUT="$(git status --porcelain)"
if [[ -n "${CI-""}" ]]; then
  printf "(using v$(mint run NickLockwood/SwiftFormat@"$SWIFT_FORMAT_VERSION" --version)) "
  mint run NickLockwood/SwiftFormat@"$SWIFT_FORMAT_VERSION" . > /dev/null 2>&1
else
  printf "(using v$(swiftformat --version)) "
  swiftformat . > /dev/null 2>&1
fi
SECOND_OUT="$(git status --porcelain)"
if [[ "$FIRST_OUT" != "$SECOND_OUT" ]]; then
  printf "\033[0;31mformatting issues!\033[0m\n"
  git --no-pager diff
  exit 1
else
  printf "\033[0;32mokay.\033[0m\n"
fi
exit
