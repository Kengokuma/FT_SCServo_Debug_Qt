#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
PROJECT_DIR=$(cd "${SCRIPT_DIR}/.."; pwd)
PACKAGE=ft-scservo-debug-qt
VERSION=${1:-1.1.1}
ARCH=${2:-$(dpkg --print-architecture)}
OUTPUT="${SCRIPT_DIR}/${PACKAGE}_${VERSION}_${ARCH}.deb"
STAGING_DIR=$(mktemp -d)

cleanup()
{
    rm -rf "${STAGING_DIR}"
}
trap cleanup EXIT

qmake "${PROJECT_DIR}/FT_SCServo_Debug_Qt.pro" -o "${PROJECT_DIR}/Makefile"
make -C "${PROJECT_DIR}" clean
make -C "${PROJECT_DIR}" -j"$(nproc)"

install -Dm755 "${PROJECT_DIR}/FT_SCServo_Debug_Qt" \
    "${STAGING_DIR}/usr/bin/FT_SCServo_Debug_Qt"
mkdir -p "${STAGING_DIR}/DEBIAN"

printf '%s\n' \
    "Package: ${PACKAGE}" \
    "Version: ${VERSION}" \
    "Section: electronics" \
    "Priority: optional" \
    "Architecture: ${ARCH}" \
    "Depends: libqt5core5a, libqt5gui5, libqt5widgets5, libqt5serialport5" \
    "Maintainer: Kotakku <Kotakkucu@gmail.com>" \
    "Description: Qt utility for configuring FEETECH SCS/STS servos" \
    > "${STAGING_DIR}/DEBIAN/control"

dpkg-deb --build --root-owner-group "${STAGING_DIR}" "${OUTPUT}"
echo "Created ${OUTPUT}"
