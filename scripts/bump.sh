#!/usr/bin/env bash
#
# Point the cask at the newest ThinkWatch Lite release.
#
# **The published `.sha256` file is not a verification.** It sits next to
# the zip, on the same server, signed by nothing — whoever could replace
# one could replace the other. It is there for people who download by
# hand and want to check what they got.
#
# So this hashes the bytes it actually downloaded, and records that. The
# published sum is compared against it afterwards, which turns a mismatch
# into a failed bump rather than a cask that installs a file nobody meant
# to publish.
set -euo pipefail

cd "$(dirname "$0")/.."

REPO="ThinkWatchProject/ThinkWatch-Lite"
CASK="Casks/thinkwatch-lite.rb"

TAG=$(gh release view --repo "${REPO}" --json tagName -q .tagName)
VERSION="${TAG#v}"
HAVE=$(awk -F'"' '/^  version /{ print $2; exit }' "${CASK}")

if [[ "${HAVE}" == "${VERSION}" ]]
then
  echo "Already on ${VERSION}"
  exit 0
fi

ASSET="ThinkWatch-Lite-${VERSION}-arm64.zip"
TMP=$(mktemp -d)
# shellcheck disable=SC2064  # expand now: this is the directory to remove
trap "rm -rf '${TMP}'" EXIT

gh release download "${TAG}" --repo "${REPO}" --dir "${TMP}" \
  --pattern "${ASSET}" --pattern "${ASSET}.sha256"

SUM=$(shasum -a 256 "${TMP}/${ASSET}" | awk '{ print $1 }')
PUBLISHED=$(awk '{ print $1 }' "${TMP}/${ASSET}.sha256")

if [[ "${SUM}" != "${PUBLISHED}" ]]
then
  echo "The release's own checksum does not match the file next to it:" >&2
  echo "  ${ASSET}         ${SUM}" >&2
  echo "  ${ASSET}.sha256  ${PUBLISHED}" >&2
  echo "Not bumping. Something is wrong upstream." >&2
  exit 1
fi

sed \
  -e "s|^  version \".*\"$|  version \"${VERSION}\"|" \
  -e "s|^  sha256 \".*\"$|  sha256 \"${SUM}\"|" \
  "${CASK}" >"${TMP}/cask.rb"
mv "${TMP}/cask.rb" "${CASK}"

# Assert rather than assume. A `sed` that matched nothing exits 0, and the
# commit step would then push a cask with the old version and a straight
# face.
grep -qx "  version \"${VERSION}\"" "${CASK}"
grep -qx "  sha256 \"${SUM}\"" "${CASK}"

echo "${HAVE} -> ${VERSION}"
echo "sha256 ${SUM}"
