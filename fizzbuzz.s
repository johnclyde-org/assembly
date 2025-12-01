// FizzBuzz - ARM64 macOS
// Demonstrates: conditionals, modulo, string selection, loops

.global _main
.align 4

.text

// print_string - print string of given length
// Input: x0 = address, x1 = length
print_string:
    mov     x2, x1
    mov     x1, x0
    mov     x0, #1
    mov     x16, #4
    svc     #0x80
    ret

// print_number - print integer followed by newline
// Input: x0 = number
print_number:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    sub     sp, sp, #32

    mov     x9, x0                  // number to convert
    add     x10, sp, #30            // buffer end position
    mov     x11, x10                // save end for length calc

    // newline at end
    mov     w12, #'\n'
    strb    w12, [x10]
    sub     x10, x10, #1

    // convert digits right-to-left
    mov     x13, #10
1:  udiv    x14, x9, x13            // quotient
    msub    x15, x14, x13, x9       // remainder
    add     x15, x15, #'0'
    strb    w15, [x10]
    sub     x10, x10, #1
    mov     x9, x14
    cbnz    x9, 1b

    // write(stdout, buffer, length)
    add     x1, x10, #1             // start of digits
    sub     x2, x11, x10            // length including newline
    mov     x0, #1
    mov     x16, #4
    svc     #0x80

    add     sp, sp, #32
    ldp     x29, x30, [sp], #16
    ret

_main:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    mov     x29, sp

    mov     x19, #1                     // counter (1 to 100)

fizzbuzz_loop:
    mov     x20, #0                     // printed flag

    // Check divisible by 15 (FizzBuzz)
    mov     x1, #15
    udiv    x2, x19, x1
    msub    x3, x2, x1, x19
    cbnz    x3, check_3

    adrp    x0, fizzbuzz@PAGE
    add     x0, x0, fizzbuzz@PAGEOFF
    mov     x1, #8
    bl      print_string
    mov     x20, #1
    b       next

check_3:
    // Check divisible by 3 (Fizz)
    mov     x1, #3
    udiv    x2, x19, x1
    msub    x3, x2, x1, x19
    cbnz    x3, check_5

    adrp    x0, fizz@PAGE
    add     x0, x0, fizz@PAGEOFF
    mov     x1, #4
    bl      print_string
    mov     x20, #1
    b       next

check_5:
    // Check divisible by 5 (Buzz)
    mov     x1, #5
    udiv    x2, x19, x1
    msub    x3, x2, x1, x19
    cbnz    x3, print_num

    adrp    x0, buzz@PAGE
    add     x0, x0, buzz@PAGEOFF
    mov     x1, #4
    bl      print_string
    mov     x20, #1
    b       next

print_num:
    mov     x0, x19
    bl      print_number
    b       continue

next:
    // Already printed fizz/buzz/fizzbuzz, just need newline
    cbz     x20, continue
    adrp    x0, newline@PAGE
    add     x0, x0, newline@PAGEOFF
    mov     x1, #1
    bl      print_string

continue:
    add     x19, x19, #1
    cmp     x19, #101
    b.lt    fizzbuzz_loop

    // exit(0)
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    mov     x0, #0
    mov     x16, #1
    svc     #0x80

.data
fizz:       .ascii "Fizz"
buzz:       .ascii "Buzz"
fizzbuzz:   .ascii "FizzBuzz"
newline:    .ascii "\n"
