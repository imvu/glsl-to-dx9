#!/bin/bash

set -e

angle-binaries/essl_to_hlsl.exe -o -b=h9 -s=w "$1" | grep -v '###' > "$1".hlsl
/c/Program\ Files\ \(x86\)/Windows\ Kits/8.1/bin/x64/fxc.exe /nologo /E gl_main /O2 /T vs_3_0 "$1".hlsl #/Fc "$1".asm
