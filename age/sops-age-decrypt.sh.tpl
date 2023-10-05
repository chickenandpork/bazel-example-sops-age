#!/bin/bash

set -e
set -o pipefail

function decrypt_file() {
    # order is important here: age before decrypt
    SOPS_AGE_KEY_FILE={RECIPIENT_FILE} {SOPS_BINARY_PATH} --decrypt $1 > $2
}

{DEBUG} && set -x

# This is expanded to calls to the above function
{DECRYPT_FILES}
