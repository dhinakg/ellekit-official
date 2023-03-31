#!/bin/bash

set -e

GPG_KEY="71C9AF96CD2F3A8A837EFFBB015D4A9B1D4A2370"
POOL_DIR="pool"
STATIC_DIR="static"
OUTPUT_DIR="deploy"

cd "$(dirname "$0")" || exit 1

compress() {
    lz4 -c9 "$1" >"$1.lz4"
    zstd -q -c19 "$1" >"$1.zst"
    xz -c9 "$1" >"$1.xz"
    bzip2 -c9 "$1" >"$1.bz2"
    gzip -nc9 "$1" >"$1.gz"
    lzma -c9 "$1" >"$1.lzma"
}

rm -r $OUTPUT_DIR >/dev/null 2>&1 || true
if [ -e $STATIC_DIR ]; then
    cp -r $STATIC_DIR $OUTPUT_DIR
else
    mkdir $OUTPUT_DIR
fi


apt-ftparchive packages $POOL_DIR >$OUTPUT_DIR/Packages
compress $OUTPUT_DIR/Packages

apt-ftparchive --arch iphoneos-arm contents $POOL_DIR >$OUTPUT_DIR/Contents-iphoneos-arm
compress $OUTPUT_DIR/Contents-iphoneos-arm

apt-ftparchive --arch iphoneos-arm64 contents $POOL_DIR >$OUTPUT_DIR/Contents-iphoneos-arm64
compress $OUTPUT_DIR/Contents-iphoneos-arm64

apt-ftparchive \
    --contents \
    -o APT::FTPArchive::Release::Origin="ElleKit" \
    -o APT::FTPArchive::Release::Label="Official ElleKit builds" \
    -o APT::FTPArchive::Release::Suite="stable" \
    -o APT::FTPArchive::Release::Version="1.0" \
    -o APT::FTPArchive::Release::Codename="ellekit" \
    -o APT::FTPArchive::Release::Architectures="iphoneos-arm iphoneos-arm64" \
    -o APT::FTPArchive::Release::Components="main" \
    -o APT::FTPArchive::Release::Description="Official ElleKit repo." \
    release $OUTPUT_DIR >$OUTPUT_DIR/Release

gpg -vabs -u $GPG_KEY -o $OUTPUT_DIR/Release.gpg $OUTPUT_DIR/Release
gpg --clearsign -u $GPG_KEY -o $OUTPUT_DIR/InRelease $OUTPUT_DIR/Release

cp -r pool "$OUTPUT_DIR"

echo "Done!"
