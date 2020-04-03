#!/bin/bash
# Creates a tarball from a Git snapshot.
# This reads Debian package versions in the format majorversion~commithash-debrevision.
set -e

URL="https://github.com/withmorten/spek-alternative"

PACKAGE="$(dpkg-parsechangelog --show-field Source)"
VERSION="$(dpkg-parsechangelog --show-field Version)"
ORIG_VERSION="$(rev <<< $VERSION | cut -f 2- -d '-' | rev)"
OUTPATH="../../${PACKAGE}_${ORIG_VERSION}.orig.tar.gz"

if [[ "$ORIG_VERSION" == *"~"* ]]; then
	COMMIT="$(rev <<< $ORIG_VERSION | cut -f 1 -d '~' | rev)"
else
	# If no tilde exists in the orig version, just treat it as the tag.
	COMMIT="$VERSION"
fi

echo "Source package name: $PACKAGE"
echo "debian/changelog version: $VERSION"
echo "Upstream part of version: $ORIG_VERSION"
echo "Using Git commit-ish: $COMMIT"

set -x
git clone "$URL" "${PACKAGE}-${ORIG_VERSION}"

echo "# Generating archive from commit."
pushd "${PACKAGE}-${ORIG_VERSION}"
git archive -v "$COMMIT" -o "$OUTPATH"
popd

echo "# Removing temporary Git tree."
rm -rf "${PACKAGE}-${ORIG_VERSION}"

echo "Done - written to $OUTPATH"
