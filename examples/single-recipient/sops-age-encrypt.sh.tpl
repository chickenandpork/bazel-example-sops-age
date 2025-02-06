#!/bin/bash

set -e
set -o pipefail

function encrypt_file() {
    {DEBUG} && set -x
    # order is important here: age before encrypt
    {SOPS_BINARY_PATH} --age $(join_comma "${recipient_pubkeys[@]}") --encrypt $1 > $2
}

function join_char_sep() {
    # join a list of items by separator in argv[1]
    local IFS="$1"; shift

    echo "$*"
}
function join_comma() { local IFS=","; echo "$*"; }

function rec_parse() {
    awk '/public key:/ {print $NF}' $1
}

recipient_pubkeys=()

{DEBUG} && set -x
# Expanded to parse recipient files for public keys
{RECIPIENT_FILES}
{DEBUG} && echo "recipients: ${recipient_pubkeys[@]}"
JOINED=$(join_comma "${recipient_pubkeys[@]}")
{DEBUG} && echo "joined: ${JOINED}"

# This is expanded to calls to the above function
{ENCRYPT_FILES}
