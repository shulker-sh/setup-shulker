#!/bin/sh
# release.sh publishes a release of the action at origin/master, such as v1.2.0, and moves its major
# tag, v1, to the same commit. Workflows that name @v1 get it on their next run; a pin by commit
# hears about it from Dependabot.
set -eu

fail() {
  echo "error: $1" >&2
  exit 1
}

[ $# -eq 1 ] || fail "usage: scripts/release.sh v1.2.0"
version="$1"
case "$version" in
  v[0-9]*.[0-9]*.[0-9]*) ;;
  *) fail "$version isn't a version like v1.2.0" ;;
esac
major="${version%%.*}"

cd "$(dirname "$0")/.."
git fetch -q origin master
head="$(git rev-parse origin/master)"
[ "$(git rev-parse HEAD)" = "$head" ] || fail "HEAD isn't origin/master: push master, then run this again"

gh release create "$version" --repo shulker-sh/setup-shulker --target "$head" --title "$version" --generate-notes
git fetch -q origin "refs/tags/$version:refs/tags/$version"
git tag -f "$major" "$head" >/dev/null
git push -q -f origin "refs/tags/$major"
echo "Released $version at $(printf '%.7s' "$head") and moved $major to it"
