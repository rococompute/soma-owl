#!/bin/sh
set -eu
switch=${SOMA_OCAML_SWITCH:-$HOME/.cache/soma/ocaml}
if [ "$(uname -s)" = Darwin ] && command -v brew >/dev/null 2>&1; then
  llvm_prefix=$(brew --prefix llvm)
  omp_prefix=$(brew --prefix libomp)
  blas_prefix=$(brew --prefix openblas)
  [ -x "$llvm_prefix/bin/clang" ] && [ -f "$omp_prefix/lib/libomp.dylib" ] || {
    echo 'Install native prerequisites: brew install openblas llvm libomp' >&2; exit 1;
  }
  compiler_bin=$(mktemp -d)
  trap 'rm -rf "$compiler_bin"' EXIT HUP INT TERM
  ln -s "$llvm_prefix/bin/clang" "$compiler_bin/cc"
  ln -s "$llvm_prefix/bin/clang++" "$compiler_bin/c++"
  export PATH="$compiler_bin:$PATH"
  export CPATH="$omp_prefix/include${CPATH:+:$CPATH}"
  export LIBRARY_PATH="$omp_prefix/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
  export PKG_CONFIG_PATH="$blas_prefix/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  export OWL_CFLAGS="${OWL_CFLAGS:--O3 -DSFMT_MEXP=19937 -Wno-error=incompatible-pointer-types}"
  export OWL_LDFLAGS="-L$omp_prefix/lib -lomp${OWL_LDFLAGS:+ $OWL_LDFLAGS}"
fi
opam install --switch="$switch" -y --assume-depexts --jobs="${SOMA_OWL_JOBS:-4}" owl.1.2
