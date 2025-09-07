## Zolana counter program

### Compiler

First, you need a zig compiler built with Solana's LLVM fork. See the README of
[solana-zig-bootstrap](https://github.com/joncinque/solana-zig-bootstrap)
on how to build it, or you can download it from the
[GitHub releases page](https://github.com/joncinque/solana-zig-bootstrap/releases).

There is also a helper script which will install it to the current directory:

```console
./install-solana-zig.sh
```

### Dependencies

```console
zig fetch --save https://github.com/joncinque/solana-program-library-zig/archive/refs/tags/v0.15.1.tar.gz
zig fetch --save https://github.com/joncinque/solana-program-sdk-zig/archive/refs/tags/v0.16.3.tar.gz
```

### Build

You can build the program by running:

```console
./solana-zig/zig build
```