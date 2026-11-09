#!/usr/bin/env bash
# Builds the package and publishes it with a new database in the pacman repository "voice-commands",
# which lives in the GitHub release with the tag "repo". Only the newest version is kept there.
# Packages and database are not signed (the maintainer's decision): pacman trusts them because they
# come over HTTPS from this GitHub repository. Needs gh logged in to an account that may change the
# releases.
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")/.."
REPO=deehax999-source/voice-commands
TAG=repo
DB=voice-commands

for tool in gh repo-add makepkg; do
    command -v "$tool" >/dev/null || { echo "$tool is missing." >&2; exit 1; }
done
[ -z "$(git status --porcelain)" ] || { echo "Commit your changes first, so that the package matches GitHub." >&2; exit 1; }
[ "$(git rev-parse HEAD)" = "$(git rev-parse '@{upstream}' 2>/dev/null)" ] ||
    { echo "Push your commits first, so that the package matches GitHub." >&2; exit 1; }

packaging/build-package.sh >/dev/null
OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT
(cd aur && PKGDEST="$OUT" makepkg --force --cleanbuild --clean >/dev/null)
PKG=$(find "$OUT" -maxdepth 1 -name 'voice-commands-*.pkg.tar.zst' -printf '%f\n')
[ -n "$PKG" ] || { echo "makepkg made no package." >&2; exit 1; }

# A new database with only this package; pacman reads $DB.db, and release files cannot be links
repo-add --quiet "$OUT/$DB.db.tar.gz" "$OUT/$PKG"
for ext in db files; do
    cp --remove-destination "$OUT/$DB.$ext.tar.gz" "$OUT/$DB.$ext"
done

# The tag stays "repo", because pacman.conf names it; the title shows the version
VERSION=$(sed -n 's/^pkgver=//p' packaging/PKGBUILD)
NOTES="Voice Commands $VERSION in its pacman repository. Add the repository as described in the README under Installation; you do not need to download these files yourself. What changed is in CHANGELOG.md."
gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1 ||
    gh release create "$TAG" --repo "$REPO" --title "Voice Commands $VERSION" --notes "$NOTES"
old=$(gh release view "$TAG" --repo "$REPO" --json assets --jq '.assets[].name' | grep '\.pkg\.tar\.zst$' | grep -vxF "$PKG" || true)
# The package first and the database last, so that the database never names a missing package
gh release upload "$TAG" --repo "$REPO" --clobber "$OUT/$PKG"
gh release upload "$TAG" --repo "$REPO" --clobber "$OUT/$DB.files"
gh release upload "$TAG" --repo "$REPO" --clobber "$OUT/$DB.db"
for name in $old; do
    gh release delete-asset "$TAG" "$name" --repo "$REPO" --yes
done
# Renamed only now, so that a failed upload does not show a version that is not there
gh release edit "$TAG" --repo "$REPO" --title "Voice Commands $VERSION" --notes "$NOTES" >/dev/null
echo "Published $PKG in the repository $DB."
