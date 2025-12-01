# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ARM64 macOS assembly language examples using GNU Assembler (GAS) syntax.

## Build Commands

```bash
make              # Build all programs
make clean        # Remove object files and binaries
make run-all      # Build and run all examples
```

Build individual programs:
```bash
make hello        # Build hello world
make factorial    # Build factorial calculator
make fizzbuzz     # Build fizzbuzz
```

Manual assembly (without Makefile):
```bash
as -o program.o program.s
ld -lSystem -syslibroot $(xcrun -sdk macosx --show-sdk-path) -e _main -arch arm64 -o program program.o
```

## Architecture Notes

- Target: ARM64 (Apple Silicon)
- Calling convention: macOS ARM64 ABI
- System calls use `svc #0x80` with syscall number in x16
- Entry point must be `_main` (underscore prefix required on macOS)

## File Conventions

- `.s` - GNU Assembler (GAS) syntax files
- Object files (`*.o`), binaries, and debug directories (`*.dSYM/`) are gitignored
