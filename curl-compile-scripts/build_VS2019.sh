#!/bin/bash

real_path() {
	[[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REL_SCRIPT_PATH="$(dirname $0)"
SCRIPTPATH=$(real_path $REL_SCRIPT_PATH)
CURLPATH="$SCRIPTPATH/../curl"

#Configure cURL
cd $CURLPATH
mkdir -p build-vc142 && cd build-vc142

cmake -G"Visual Studio 16 2019" .. \
	-DCMAKE_USE_WINSSL=ON \
	-DBUILD_CURL_EXE=OFF \
	-DBUILD_SHARED_LIBS=OFF \
	-DBUILD_TESTING=OFF

cmake --build . -- //p:Configuration=Debug
cmake --build . -- //p:Configuration=Release

DESTDIR=$SCRIPTPATH/../prebuilt-with-ssl/vc142-x64-winssl
cp -R lib/Debug lib/Release "$DESTDIR"

#Copying cURL headers
if [ -d "$DESTDIR/include" ]; then
	echo "Cleaning headers"
	rm -rf "$DESTDIR/include"
fi
cp -R $CURLPATH/include $DESTDIR/
rm $DESTDIR/include/curl/.gitignore

cd $PWD
exit 0
