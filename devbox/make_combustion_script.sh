#!/usr/bin/env sh

# Prints an error and immediately terminates the script with error
# code `1`:
# `$1`: Error message
error() {
    echo "Error: $1"
    exit 1
}

# Gets the absolute path of the directory containging the file specified.
# `$1`: Filename
absdir() {
    cd -- "$(dirname "$1")" && pwd
}

SCRIPT_DIR=$(absdir "${0}") || error error "Can't determine absolute path for $0"
SECRETS_FILE=${SCRIPT_DIR}/secrets
COMBUSTION_TPL_FILE=${SCRIPT_DIR}/combustion.tpl.sh
COMBUSTION_FILE=${SCRIPT_DIR}/combustion.sh

if [ ! -r "${SECRETS_FILE}" ]; then
    error "Secrets file missing or not specified"
fi

set -a
# shellcheck source=/dev/null
. "${SECRETS_FILE}"
set +a

# shellcheck disable=SC2016
envsubst '$TRENTO_VAGRANT_REGCODE' \
         < "${COMBUSTION_TPL_FILE}" \
         > "${COMBUSTION_FILE}" \
    || error "Failed during substitution step"

echo "Done -- ${COMBUSTION_FILE} created"
