#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# lefthook >=2.2.3 built with -buildmode=pie segfaults at startup on linux-ppc64le
if [[ ${target_platform} == linux-ppc64le ]]; then
    BUILDMODE=exe
else
    BUILDMODE=pie
fi

go build -trimpath -buildmode=${BUILDMODE} -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w"
go-licenses save . --save_path=license-files

if [[ ${build_platform} == ${target_platform} ]]; then
    mkdir -p ${PREFIX}/etc/bash_completion.d
    mkdir -p ${PREFIX}/fish/vendor_completions.d
    mkdir -p ${PREFIX}/zsh/site-functions
    lefthook completion bash > ${PREFIX}/etc/bash_completion.d/lefthook
    lefthook completion fish > ${PREFIX}/fish/vendor_completions.d/lefthook.fish
    lefthook completion zsh > ${PREFIX}/zsh/site-functions/_lefthook
fi
