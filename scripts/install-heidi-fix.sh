#!/usr/bin/env bash
# Downloads the native program of this release for the platform of the runner to $RUNNER_TEMP/heidi-fix, checks its SHA-256, and gives its path.
# The script runs on Linux and on macOS, so it uses only the options that the BSD tools also know.
set -euo pipefail

release_tag="v0.1.0-alpha.7"
download_url="https://github.com/MeterianHQ/heidi-fix-public/releases/download/${release_tag}"
install_directory="${RUNNER_TEMP}/heidi-fix"
program="${install_directory}/heidi-fix"

case "${RUNNER_OS:-} ${RUNNER_ARCH:-}" in
  "Linux X64")
    platform=linux-x64
    expected_sha256="38d3c5b0554b3cfe282f3db277e6ea98da61c80ce1c474a8b472919bd5fccf28"
    ;;
  "Linux ARM64")
    platform=linux-arm64
    expected_sha256="22b04313473dd4da4ead1e349e1d003cf32f7c28f15e5b5bfb077cea6a08ee98"
    ;;
  "macOS ARM64")
    platform=macos-arm64
    expected_sha256="ed2b8762210124d851f4e0c93e27287b64e2e74b07a0205db3e827e5fa4c9069"
    ;;
  *)
    echo "::error::Heidi Fix has no program for the runner ${RUNNER_OS:-unknown} ${RUNNER_ARCH:-unknown}. Use a runner Linux X64, Linux ARM64, or macOS ARM64."
    exit 1
    ;;
esac

# macOS has no sha256sum, so the script uses shasum there.
compute_sha256() {
  if [ "$RUNNER_OS" = macOS ]; then
    shasum -a 256 "$1" | cut -d ' ' -f 1
  else
    sha256sum "$1" | cut -d ' ' -f 1
  fi
}

mkdir -p "$install_directory"
curl --proto '=https' --fail --silent --show-error --location --retry 3 --retry-connrefused \
  --output "$program" "${download_url}/heidi-fix-${platform}"
if [ "$(compute_sha256 "$program")" != "$expected_sha256" ]; then
  rm -f "$program"
  echo "::error::The SHA-256 of heidi-fix-${platform} ${release_tag} is not correct. Do not use this program."
  exit 1
fi
chmod +x "$program"
echo "HEIDI_FIX_PROGRAM=${program}" >> "$GITHUB_ENV"
