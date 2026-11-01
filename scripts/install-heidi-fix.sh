#!/usr/bin/env bash
# Downloads the native program of this release for the platform of the runner to $RUNNER_TEMP/heidi-fix, checks its SHA-256, and gives its path.
# The script runs on Linux and on macOS, so it uses only the options that the BSD tools also know.
set -euo pipefail

release_tag="v0.1.0-alpha.9"
download_url="https://github.com/MeterianHQ/heidi-fix-public/releases/download/${release_tag}"
install_directory="${RUNNER_TEMP}/heidi-fix"
program="${install_directory}/heidi-fix"

case "${RUNNER_OS:-} ${RUNNER_ARCH:-}" in
  "Linux X64")
    platform=linux-x64
    expected_sha256="7afadaa9eb7d2b3f16570c2ad5be1fdc3be0e3426cc05ec12fdeba912b4061f6"
    ;;
  "Linux ARM64")
    platform=linux-arm64
    expected_sha256="0f7b9adb206de8b7c2548ee4b6a4a38b56d0046fa289db3cad6ce750f6bafb64"
    ;;
  "macOS ARM64")
    platform=macos-arm64
    expected_sha256="ccf3ce7c6ea5d3c81a81ef76ab1762c6340d55eb3c61f9fd8460fd4d9cc11711"
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
