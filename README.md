# soma-owl

A small Soma package for [Owl 1.2](https://github.com/owlbarn/owl), OCaml's
numerical computing library. It exposes double-precision dense matrices and
a one-hidden-layer classifier. This is a deliberately small binding surface,
not bindings for all of Owl.

- `matrix.definition` declares the numerical API.
- `matrix.ml` adapts lists to Owl's matrix arrays, fixes reduction axes, and
  supplies seeded initialization and cross-entropy. Numerical operations are
  `Owl.Dense.Matrix.D` operations.
- `nn/mlp.soma` implements network construction, tanh/softmax forward
  propagation, cross-entropy gradients, and full-batch gradient descent.
- `test/main.soma` checks an Owl matrix product and trains nonlinear XOR.

## Use from another project

Use the canonical HTTPS dependency below. If GitHub restricts repository
access, authenticate the building account first (for example, `gh auth login`
and `gh auth setup-git`), or use its authenticated SSH URL. The optional Owl
example requires this dependency and the native Owl toolchain.

```toml
[project]
name = "my_classifier"
version = "0.1.0"

[dependencies]
"https://github.com/rococompute/soma-owl.git" = "0.1.0"

[opam]
owl = "1.2"
```

```coq
Import soma_owl.matrix soma_owl.nn.mlp.

inputs := matrix.of_rows [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]]%float.
targets := matrix.of_rows [[1.0, 0.0], [0.0, 1.0], [0.0, 1.0], [1.0, 0.0]]%float.
initial := initialize 2 8 2 17.
fitted := train 1500 0.5%float inputs targets initial.
main := matrix.format_float (loss fitted inputs targets).
```

`soma run main.soma` fetches the version tag using Git's configured credentials and writes `soma.lock`.
Commit that lockfile. `Import soma_owl.nn.mlp.` names a file in the package;
imports in the package itself remain relative to its own project root.

The matrices have the usual batch-by-feature layout. Inputs must be nonempty
rectangular matrices, targets batch-by-class probability distributions whose
rows sum to one, and the model's dimensions must match. These dimensions are
checked by the underlying runtime operations, not proven in Soma's types.
Foreign matrix operations are opaque to the kernel and execute only after
compilation; the wrapper adds no proof that Owl's numerical results are correct.

The classifier uses deterministic local seeds and functional updates. It does
not mutate an input model, serialize weights, or require an external dataset.
The tic-tac-toe example in Soma's `examples/example_projects/owl_tictactoe`
contains the game rules, minimax teacher, training data, and legal-move mask.

## Native prerequisites and tests

Owl needs OpenBLAS/LAPACKE and an OCaml program switch. Soma normally installs
its OCaml packages when a program uses them. Install the system libraries first:

- Debian/Ubuntu: `sudo apt-get install libopenblas-dev liblapacke-dev`.
- Homebrew: `brew install openblas llvm libomp`.

On this Apple Silicon machine, Homebrew's OpenBLAS includes OpenMP compiler
flags. Apple Clang rejects the plain `-fopenmp` flag. `scripts/install-owl.sh`
uses Homebrew LLVM for the Owl installation and links the OpenMP runtime. It
also accommodates Owl 1.2's existing native-dimension pointer warning under
new Clang. Elsewhere it runs the normal opam installation.

```sh
./scripts/install-owl.sh
./test/run.sh
```

`SOMA_OCAML_SWITCH` selects the program switch (default
`~/.cache/soma/ocaml`); `SOMA_OWL_JOBS` sets installation jobs (default 4).
For this tiny workload, the test uses one OpenBLAS/OpenMP thread. No neural
network test or training runs when the package is fetched or imported.
