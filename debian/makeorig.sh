#!/bin/bash
# Creates a tarball from a Git snapshot.
# This reads Debian package versions in the format majorversion~commithash-debrevision.
set -e

URL="https://github.com/withmorten/spek-alternative"
FILES_EXCLUDED=("dist/debian")

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

pushd "${PACKAGE}-${ORIG_VERSION}"
echo "# Writing .gitattributes file for FILES_EXCLUDED"
for file in "${FILES_EXCLUDED[@]}"; do
	echo "$file export-ignore" >> .gitattributes
done

echo "# Generating archive from commit."
git archive -v "$COMMIT" -o "$OUTPATH" --worktree-attributes
popd

echo "# Removing temporary Git tree."
rm -rf "${PACKAGE}-${ORIG_VERSION}"

echo "Done - written to $OUTPATH"
