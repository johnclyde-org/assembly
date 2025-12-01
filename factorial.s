// Factorial Calculator - ARM64 macOS
// Demonstrates: recursion, stack frames, function calls, integer-to-string conversion

.global _main
.align 4

.text

// factorial(n) - recursive implementation
// Input: x0 = n
// Output: x0 = n!
factorial:
    stp     x29, x30, [sp, #-16]!   // save frame pointer and return address
    mov     x29, sp

    cmp     x0, #1
    b.le    base_case

    stp     x19, x20, [sp, #-16]!   // save callee-saved registers
    mov     x19, x0                  // save n

    sub     x0, x0, #1              // n - 1
    bl      factorial               // recursive call

    mul     x0, x0, x19             // n * factorial(n-1)

    ldp     x19, x20, [sp], #16     // restore callee-saved registers
    b       done

base_case:
    mov     x0, #1

done:
    ldp     x29, x30, [sp], #16     // restore frame pointer and return address
    ret

// print_number - convert integer to string and print
// Input: x0 = number to print
print_number:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    sub     sp, sp, #32             // buffer space

    mov     x9, x0                  // number to convert
    mov     x10, sp                 // buffer pointer (end)
    add     x10, x10, #30
    mov     x11, x10                // save end position

    // add newline at end
    mov     w12, #10
    strb    w12, [x10]
    sub     x10, x10, #1

    // convert digits (reverse order)
    mov     x13, #10
convert_loop:
    udiv    x14, x9, x13            // x14 = x9 / 10
    msub    x15, x14, x13, x9       // x15 = x9 - (x14 * 10) = remainder
    add     x15, x15, #'0'          // convert to ASCII
    strb    w15, [x10]
    sub     x10, x10, #1
    mov     x9, x14
    cbnz    x9, convert_loop

    // write the number
    add     x10, x10, #1            // point to first digit
    mov     x0, #1                  // stdout
    mov     x1, x10                 // buffer start
    sub     x2, x11, x10
    add     x2, x2, #1              // length including newline
    mov     x16, #4                 // write syscall
    svc     #0x80

    add     sp, sp, #32
    ldp     x29, x30, [sp], #16
    ret

// print_string - print a null-terminated string
// Input: x0 = string address, x1 = length
print_string:
    mov     x2, x1                  // length
    mov     x1, x0                  // string address
    mov     x0, #1                  // stdout
    mov     x16, #4                 // write syscall
    svc     #0x80
    ret

_main:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // Print header
    adrp    x0, header@PAGE
    add     x0, x0, header@PAGEOFF
    mov     x1, #22
    bl      print_string

    // Calculate and print factorials 1! through 12!
    mov     x19, #1                 // counter

loop:
    mov     x0, x19
    bl      factorial
    bl      print_number

    add     x19, x19, #1
    cmp     x19, #13
    b.lt    loop

    // exit(0)
    mov     x0, #0
    mov     x16, #1
    svc     #0x80

.data
header:
    .ascii "Factorials 1! to 12!:\n"
