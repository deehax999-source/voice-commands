#!/usr/bin/env bash
# Builds the flat package folder ./aur, with checksums and .SRCINFO, from which makepkg builds the package.
# The folder name stays aur/ so that existing copies and the install steps keep working.
# Bump pkgver or pkgrel in packaging/PKGBUILD before publishing a change.
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")/.."
for tool in updpkgsums makepkg; do
    command -v "$tool" >/dev/null || { echo "$tool is missing. Install it with: sudo pacman -S --needed pacman-contrib base-devel" >&2; exit 1; }
done

OUT="${1:-aur}"
mkdir -p "$OUT"
find "$OUT" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
# Only files, so that caches such as __pycache__ do not stop the build
find bin hypr desktop -maxdepth 1 -type f -exec cp -t "$OUT/" {} +
cp skill/SKILL.md README.md LICENSE packaging/PKGBUILD packaging/voice-commands.install "$OUT/"
# The AUR folder is flat, so the general help files get a prefix
cp help/de.md "$OUT/help-de.md"
cp help/en.md "$OUT/help-en.md"
cp help/welcome.*.md "$OUT/"

cd "$OUT"
updpkgsums >/dev/null 2>&1
makepkg --printsrcinfo >.SRCINFO
rm -rf src pkg
echo "Ready: $PWD"
ls -A | grep -v '^\.git$' | tr '\n' ' '
echo
