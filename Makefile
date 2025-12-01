# ARM64 macOS Assembly Makefile

AS = as
LD = ld
SDK = $(shell xcrun -sdk macosx --show-sdk-path)
LDFLAGS = -lSystem -syslibroot $(SDK) -e _main -arch arm64

SOURCES = $(wildcard *.s)
OBJECTS = $(SOURCES:.s=.o)
PROGRAMS = $(SOURCES:.s=)

.PHONY: all clean run-hello run-factorial run-fizzbuzz run-fileio run-ascii_art

all: $(PROGRAMS)

# Pattern rule for assembling
%.o: %.s
	$(AS) -o $@ $<

# Explicit targets to avoid implicit rules
hello: hello.o
	$(LD) $(LDFLAGS) -o $@ $<

factorial: factorial.o
	$(LD) $(LDFLAGS) -o $@ $<

fizzbuzz: fizzbuzz.o
	$(LD) $(LDFLAGS) -o $@ $<

fileio: fileio.o
	$(LD) $(LDFLAGS) -o $@ $<

ascii_art: ascii_art.o
	$(LD) $(LDFLAGS) -o $@ $<

clean:
	rm -f $(OBJECTS) $(PROGRAMS)
	rm -rf *.dSYM

# Convenience targets
run-hello: hello
	./hello

run-factorial: factorial
	./factorial

run-fizzbuzz: fizzbuzz
	./fizzbuzz

run-fileio: fileio
	./fileio

run-ascii_art: ascii_art
	./ascii_art

run-all: all
	@echo "=== Hello World ===" && ./hello
	@echo "\n=== Factorial ===" && ./factorial
	@echo "\n=== FizzBuzz ===" && ./fizzbuzz
	@echo "\n=== File I/O ===" && ./fileio
	@echo "\n=== ASCII Art ===" && ./ascii_art
