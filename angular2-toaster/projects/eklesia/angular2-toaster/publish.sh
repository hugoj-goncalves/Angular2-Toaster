#!/bin/bash

mydir="$(dirname "$(readlink -f "$0")")"
pushd "$mydir" 2>&1 >/dev/null

npm install || exit 1
# ng test @eklesia/angular2-toaster --browsers=Chrome_no_sandbox --watch=false || exit 1

CURRENT_VERSION=$(cat package.json | grep version | grep -oP "\d[^\"]+")
echo "Current published package version for @eklesia/angular2-toaster: $CURRENT_VERSION"
echo "What should be the next version?"
read NEXT_VERSION
if [[ -z "$NEXT_VERSION" ]]; then
    NEXT_VERSION="$CURRENT_VERSION"
fi
read -p "Are you sure that the next version should be $NEXT_VERSION? (Y/n) " -n 1 -r RESPONSE
echo
if [[ ! $RESPONSE =~ ^[YySs]$ ]] && [[ ! -z $RESPONSE ]]; then
    echo "Aborting..."
    exit 1
fi
if [[ "$NEXT_VERSION" != "$CURRENT_VERSION" ]]; then
    npm version "$NEXT_VERSION" || exit 1
fi

function build() {
    if ! ng build --prod @eklesia/angular2-toaster; then
        read -p "Retry? (Y/n) " -n 1 -r RESPONSE
        echo
        if [[ ! $RESPONSE =~ ^[YySs]$ ]] && [[ ! -z $RESPONSE ]]; then
            echo "Aborting..."
            exit 1
        fi
        build
    fi
}
build

cp ./src/lib/*.css ../../dist/eklesia/angular2-toaster/
cp ./src/lib/*.scss ../../dist/eklesia/angular2-toaster/

cd ../../dist/eklesia/angular2-toaster

npm publish
