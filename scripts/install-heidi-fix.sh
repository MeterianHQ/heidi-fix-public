#!/usr/bin/env bash
# Downloads heidi-fix.jar of this release to $RUNNER_TEMP/heidi-fix, checks its SHA-256, and gives its path.
set -euo pipefail

release_tag="v0.1.0-alpha.4"
expected_sha256="0c48bc3f2a5589fc0d5fdbf5df65e0b9c9aba3e61ff81e773cfad07a87ab9b36"
download_url="https://github.com/MeterianHQ/heidi-fix-public/releases/download/${release_tag}"
install_directory="${RUNNER_TEMP}/heidi-fix"

mkdir -p "$install_directory"
cd "$install_directory"
curl --proto '=https' --fail --silent --show-error --location --retry 3 --retry-connrefused \
  --output heidi-fix.jar "${download_url}/heidi-fix.jar"
if ! echo "${expected_sha256}  heidi-fix.jar" | sha256sum --check --status; then
  echo "::error::The SHA-256 of heidi-fix.jar ${release_tag} is not correct. Do not use this jar."
  exit 1
fi
echo "HEIDI_FIX_JAR=${install_directory}/heidi-fix.jar" >> "$GITHUB_ENV"
