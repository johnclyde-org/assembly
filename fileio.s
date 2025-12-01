// File I/O - ARM64 macOS
// Demonstrates: open, read, write, close syscalls
// Creates a file, writes to it, reads it back, prints contents

.global _main
.align 4

.text

// Constants
.equ O_RDONLY, 0x0000
.equ O_WRONLY, 0x0001
.equ O_CREAT,  0x0200
.equ O_TRUNC,  0x0400

.equ SYS_EXIT,  1
.equ SYS_READ,  3
.equ SYS_WRITE, 4
.equ SYS_OPEN,  5
.equ SYS_CLOSE, 6

// print_string(addr, len)
print_string:
    mov     x2, x1
    mov     x1, x0
    mov     x0, #1
    mov     x16, #SYS_WRITE
    svc     #0x80
    ret

_main:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x29, sp

    // Print "Creating file..."
    adrp    x0, msg_creating@PAGE
    add     x0, x0, msg_creating@PAGEOFF
    mov     x1, #17
    bl      print_string

    // open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644)
    adrp    x0, filename@PAGE
    add     x0, x0, filename@PAGEOFF
    mov     x1, #(O_WRONLY | O_CREAT | O_TRUNC)
    mov     x2, #0644
    mov     x16, #SYS_OPEN
    svc     #0x80

    cmp     x0, #0
    b.lt    open_error
    mov     x19, x0                 // save fd

    // Print "Writing..."
    adrp    x0, msg_writing@PAGE
    add     x0, x0, msg_writing@PAGEOFF
    mov     x1, #11
    bl      print_string

    // write(fd, content, len)
    mov     x0, x19
    adrp    x1, file_content@PAGE
    add     x1, x1, file_content@PAGEOFF
    mov     x2, #file_content_len
    mov     x16, #SYS_WRITE
    svc     #0x80

    // close(fd)
    mov     x0, x19
    mov     x16, #SYS_CLOSE
    svc     #0x80

    // Print "Reading back..."
    adrp    x0, msg_reading@PAGE
    add     x0, x0, msg_reading@PAGEOFF
    mov     x1, #16
    bl      print_string

    // open(filename, O_RDONLY)
    adrp    x0, filename@PAGE
    add     x0, x0, filename@PAGEOFF
    mov     x1, #O_RDONLY
    mov     x16, #SYS_OPEN
    svc     #0x80

    cmp     x0, #0
    b.lt    open_error
    mov     x19, x0                 // save fd

    // read(fd, buffer, sizeof(buffer))
    mov     x0, x19
    adrp    x1, buffer@PAGE
    add     x1, x1, buffer@PAGEOFF
    mov     x2, #256
    mov     x16, #SYS_READ
    svc     #0x80
    mov     x20, x0                 // save bytes read

    // close(fd)
    mov     x0, x19
    mov     x16, #SYS_CLOSE
    svc     #0x80

    // Print "Contents:\n"
    adrp    x0, msg_contents@PAGE
    add     x0, x0, msg_contents@PAGEOFF
    mov     x1, #10
    bl      print_string

    // Print the buffer
    adrp    x0, buffer@PAGE
    add     x0, x0, buffer@PAGEOFF
    mov     x1, x20
    bl      print_string

    // Print newline
    adrp    x0, newline@PAGE
    add     x0, x0, newline@PAGEOFF
    mov     x1, #1
    bl      print_string

    // Print "Done!"
    adrp    x0, msg_done@PAGE
    add     x0, x0, msg_done@PAGEOFF
    mov     x1, #6
    bl      print_string

    // exit(0)
    mov     x0, #0
    b       exit

open_error:
    adrp    x0, msg_error@PAGE
    add     x0, x0, msg_error@PAGEOFF
    mov     x1, #18
    bl      print_string
    mov     x0, #1

exit:
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    mov     x16, #SYS_EXIT
    svc     #0x80

.data
filename:       .asciz "test_output.txt"
msg_creating:   .ascii "Creating file...\n"
msg_writing:    .ascii "Writing...\n"
msg_reading:    .ascii "Reading back...\n"
msg_contents:   .ascii "Contents:\n"
msg_done:       .ascii "Done!\n"
msg_error:      .ascii "Error opening file\n"
newline:        .ascii "\n"

file_content:   .ascii "Hello from ARM64 assembly!\nThis file was created using raw syscalls.\nPretty cool, right?\n"
.equ file_content_len, . - file_content

.bss
buffer:         .skip 256
