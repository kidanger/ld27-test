#!/bin/sh

cd ../drystal
./runner.py ld27-test repack
cd ld27-test

git checkout gh-pages
cp ../drystal/build-web/*compress* .
git commit index.html *compress* -m "update pages"
git push origin gh-pages
git checkout master
