#!/usr/bin/env bash
set -euo pipefail
# Download a known official release snapshot. If upstream moves latest, fail closed.
# ETags are object identity pins, not independent cryptographic signatures.
root="${MOON_HOME:?MOON_HOME must be an isolated toolchain directory}"
mkdir -p "$root/lib"
curl --fail --location --retry 2 --header 'If-Match: "3bd9a50698b81ecb5777e9bdc5281358-12"' \
  https://cli.moonbitlang.com/binaries/latest/moonbit-linux-x86_64.tar.gz -o "$root/moonbit.tar.gz"
curl --fail --location --retry 2 --header 'If-Match: "89da20b81608ebc6964f1b1dffd11c46"' \
  https://cli.moonbitlang.com/cores/core-latest.tar.gz -o "$root/core.tar.gz"
# SHA-256 pins for the same official 2026-10-19 objects (toolchain built 2026-10-16).
# These detect corruption/content drift; they are not upstream signatures.
echo "ba071fe56b641e71a8a190454c6a0f7983b5af2318f3ddafb4f6305eefe3ed55  $root/moonbit.tar.gz" | sha256sum --check --status
echo "91e08ef19e85bc6690a6fb80f626fe0a83984804d0064e78dc7b3909463b6dab  $root/core.tar.gz" | sha256sum --check --status
tar -xzf "$root/moonbit.tar.gz" -C "$root"
tar -xzf "$root/core.tar.gz" -C "$root/lib"
chmod +x "$root"/bin/*
export PATH="$root/bin:$PATH"
moon -C "$root/lib/core" bundle --warn-list -a --all
moon version --all
