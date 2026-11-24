#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# golang.org/x/sys v0.49.0 makes PIE binaries crash at startup on ppc64le:
# https://github.com/golang/go/issues/82324 (fixed in v0.50.0).
# Fail once upstream moves off v0.49.0 so that this workaround gets removed.
if ! grep -qE '^[[:space:]]*golang\.org/x/sys v0\.49\.0( |$)' go.mod; then
    echo "go.mod no longer requires golang.org/x/sys v0.49.0; remove the x/sys workaround from recipe/build.sh" >&2
    exit 1
fi
go get golang.org/x/sys@v0.50.0

go build -trimpath -buildmode=pie -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w"
go-licenses save . --save_path=license-files

if [[ ${build_platform} == ${target_platform} ]]; then
    mkdir -p ${PREFIX}/etc/bash_completion.d
    mkdir -p ${PREFIX}/fish/vendor_completions.d
    mkdir -p ${PREFIX}/zsh/site-functions
    lefthook completion bash > ${PREFIX}/etc/bash_completion.d/lefthook
    lefthook completion fish > ${PREFIX}/fish/vendor_completions.d/lefthook.fish
    lefthook completion zsh > ${PREFIX}/zsh/site-functions/_lefthook
fi
