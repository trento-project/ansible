#!/usr/bin/env sh

usage() {
    echo "Usage:"
    echo "$(basename "$0") <path-to-sles-kvm-image.qcow2>"
    echo ""
}

# Prints an error and immediately terminates the script with error
# code `1`:
# `$1`: Error message
error() {
    echo "Error: $1"
    exit 2
}

# Gets the absolute path of the directory containging the file specified.
# `$1`: Filename
absdir() {
    cd -- "$(dirname "$1")" && pwd
}

# Try to match SLES version from the supplied image name.
# `$1`: Image name
identify_sles() {
    echo "$1" | grep -E -o "SLES[[:digit:]]{2}-SP[[:digit:]]{1,2}"
}

if [ -z "$1" ]; then
    echo "Error: $(basename "$0") invoked with wrong number of arguments"
    echo ""
    usage
    exit 1
fi

SCRIPT_DIR=$(absdir "$0") || error "Can't determine absolute path for $0"
WORK_DIR=${SCRIPT_DIR}/_work
IMAGE_DIR=$(absdir "$1") || error "Can't determine absolute path for $1"
IMAGE_NAME=$(basename "$1")
IMAGE_PATH=${IMAGE_DIR}/${IMAGE_NAME}

mkdir -p "${WORK_DIR}" || error "can't create work dir"
trap 'rm -rf ${WORK_DIR}' EXIT

cd "${WORK_DIR}" || error "Can't move into WORK_DIR"

BOX_NAME=$(identify_sles "${IMAGE_NAME}") \
    || error "Can't identify SLES version from image name ${IMAGE_NAME}"
BOX="${BOX_NAME}.box"
CONVERTER_SCRIPT="create_box.sh"

curl -L -O \
     "https://raw.githubusercontent.com/vagrant-libvirt/vagrant-libvirt/refs/heads/main/tools/${CONVERTER_SCRIPT}" \
    || error "Can't get converter script"

chmod +x "${CONVERTER_SCRIPT}"
"./${CONVERTER_SCRIPT}" "${IMAGE_PATH}" "${BOX}"

mv "${BOX}" "${SCRIPT_DIR}/"

echo "Done -- ${SCRIPT_DIR}/${BOX} created."
