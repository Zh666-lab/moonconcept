#!/usr/bin/env bash
set -euo pipefail
# Official compiler-version URLs avoid drift when upstream updates latest.
# Upstream retains versioned downloads for a limited time; see README.
root="${MOON_HOME:?MOON_HOME must be an isolated toolchain directory}"
version='0.10.16%2Bb1a0e846e'
mkdir -p "$root/lib"
curl --fail --location --retry 2 \
  "https://cli.moonbitlang.com/binaries/$version/moonbit-linux-x86_64.tar.gz" -o "$root/moonbit.tar.gz"
curl --fail --location --retry 2 \
  "https://cli.moonbitlang.com/cores/core-$version.tar.gz" -o "$root/core.tar.gz"
# Reviewed SHA-256 digests for the versioned official archives, not signatures.
echo "84ae424cd31bc485d2cf4d3736534e52f2f265ceafb562a187b9ab26d9566212  $root/moonbit.tar.gz" | sha256sum --check --status
echo "e7db6e3c80a97af953598b374cf14f3e330918b1ca4659b141b9f550c9c0adb0  $root/core.tar.gz" | sha256sum --check --status
tar -xzf "$root/moonbit.tar.gz" -C "$root"
tar -xzf "$root/core.tar.gz" -C "$root/lib"
chmod +x "$root"/bin/*
export PATH="$root/bin:$PATH"
moon -C "$root/lib/core" bundle --warn-list -a --all
moon version --all
moonc -v | python3 -c 'import re, sys; text = sys.stdin.read(); print(text, end=""); m = re.search(r"v?(\d+)\.(\d+)\.(\d+)", text); assert m and tuple(map(int, m.groups())) >= (0, 10, 16), "moonc >= 0.10.16 required"'
