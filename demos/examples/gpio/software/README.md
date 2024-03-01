## Building and Compilation

For `debug` build:

```console
mkdir debug
cd debug
cmake -DCMAKE_BUILD_TYPE=Debug -DTOOLCHAIN_PREFIX=/your/toolchain/riscv32-unknown-elf- ..
make
```

For `release` build:

```console
mkdir release
cd release
cmake -DCMAKE_BUILD_TYPE=Release -DTOOLCHAIN_PREFIX=/your/toolchain/riscv32-unknown-elf- ..
make
```
