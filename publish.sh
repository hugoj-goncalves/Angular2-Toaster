#!/bin/bash

function build {
  npm run build-prod && sed -i.bak "s/\"exports\":\s*{/\"exports\": \{\n\t\t\".\/\*.css\"\: \".\/\*.css\",/" ./dist/angular2-toaster/package.json
}

function updateVersion {
	pushd src/angular2-toaster
    echo "New version change: $newVersion"
    oldVersionValue=$(cat package.json | grep version | grep -oP "\d+[^\"]+")
    npm version "$newVersion"
    newVersionValue=$(cat package.json | grep version | grep -oP "\d+[^\"]+")
    echo "New version value: $newVersionValue - from $oldVersionValue"
	popd
}

newVersion="$1"
if [ -z "$newVersion" ]; then
    newVersion="prerelease"
fi

git status | grep 'nothing to commit'
if [ $? -eq 1 ]; then
    echo 'Commit everything before running update script.';
    exit 1
fi

# git pull origin master
updateVersion
build || exit 2

git status | grep 'nothing to commit'
if [ $? -eq 1 ]; then
    git add -A && git commit -m "dump release files"
fi
git push

pushd dist/angular2-toaster
npm config set scope @eklesia
npm config set access public
npm publish
popd
