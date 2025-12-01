// Hello World - ARM64 macOS
// Demonstrates: system calls, data section, basic structure

.global _main
.align 4

.text
_main:
    // write(stdout, message, length)
    mov     x0, #1              // stdout file descriptor
    adrp    x1, message@PAGE
    add     x1, x1, message@PAGEOFF
    mov     x2, #14             // message length
    mov     x16, #4             // write syscall
    svc     #0x80

    // exit(0)
    mov     x0, #0              // exit code
    mov     x16, #1             // exit syscall
    svc     #0x80

.data
message:
    .ascii "Hello, World!\n"
