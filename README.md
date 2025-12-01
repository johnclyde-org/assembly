# ARM64 Assembly Examples

Learning ARM64 assembly on Apple Silicon Macs.

## Examples

| File | Description |
|------|-------------|
| `hello.s` | Hello World - syscalls and data sections |
| `factorial.s` | Recursive factorial - stack frames and function calls |
| `fizzbuzz.s` | FizzBuzz 1-100 - conditionals, modulo, loops |

## Building

```bash
make          # build all
make clean    # remove binaries
```

## Running

```bash
./hello
./factorial
./fizzbuzz
```

Or all at once:
```bash
make run-all
```

## Requirements

- macOS on Apple Silicon (M1/M2/M3)
- Xcode Command Line Tools (`xcode-select --install`)

## Resources

- [ARM64 Instruction Set](https://developer.arm.com/documentation/ddi0602/latest)
- [macOS ABI Function Call Guide](https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms)
- [macOS System Calls](https://opensource.apple.com/source/xnu/xnu-7195.81.3/bsd/kern/syscalls.master.auto.html)
