#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat
export OPENSSL_DIR=${PREFIX}
export OPENSSL_NO_VENDOR=1
export LIBGIT2_NO_VENDOR=1
export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export PKG_CONFIG_ALLOW_CROSS=1

sed -i 's/=7.4.0/9.0.6/' Cargo.toml

if [[ ${target_platform} =~ .*osx.* ]]; then
    mkdir -p ${SRC_DIR}/target/release/deps
    ln -sf ${BUILD_PREFIX}/lib/libgit2* ${SRC_DIR}/target/release/deps
fi

cd src
cargo-bundle-licenses \
    --format yaml \
    --output ${SRC_DIR}/THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path .
