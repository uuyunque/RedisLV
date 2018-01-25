#!/bin/bash
VER=$1
URL="https://github.com/jemalloc/jemalloc/releases/download/${VER}/jemalloc-${VER}.tar.bz2"
echo "Downloading $URL"
wget -O /tmp/jemalloc.tar.bz2 $URL
tar xvjf /tmp/jemalloc.tar.bz2
rm -rf jemalloc
mv jemalloc-${VER} jemalloc
echo "Use git status, add all files and commit changes."
