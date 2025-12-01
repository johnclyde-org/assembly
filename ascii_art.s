// ASCII Art Generator - ARM64 macOS
// Demonstrates: ANSI escape codes, nested loops, computed patterns
// Draws a colorful animated spiral pattern

.global _main
.align 4

.text

.equ SYS_EXIT,  1
.equ SYS_WRITE, 4

.equ WIDTH,  60
.equ HEIGHT, 30

// write_str(addr, len)
write_str:
    mov     x2, x1
    mov     x1, x0
    mov     x0, #1
    mov     x16, #SYS_WRITE
    svc     #0x80
    ret

// write_char(char)
write_char:
    stp     x29, x30, [sp, #-16]!
    sub     sp, sp, #16
    strb    w0, [sp]
    mov     x0, #1
    mov     x1, sp
    mov     x2, #1
    mov     x16, #SYS_WRITE
    svc     #0x80
    add     sp, sp, #16
    ldp     x29, x30, [sp], #16
    ret

// set_color(color_code) - set foreground color 0-7
set_color:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    mov     x19, x0

    // Write "\x1b[3Xm" where X is color
    adrp    x0, esc_color@PAGE
    add     x0, x0, esc_color@PAGEOFF
    mov     x1, #5
    bl      write_str

    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// set_color_full(color_code) - write complete escape with digit
set_color_full:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    sub     sp, sp, #16
    mov     x19, x0

    // Build "\x1b[3Xm" on stack
    mov     w0, #0x1b           // ESC
    strb    w0, [sp, #0]
    mov     w0, #'['
    strb    w0, [sp, #1]
    mov     w0, #'3'
    strb    w0, [sp, #2]
    add     w0, w19, #'0'       // color digit
    strb    w0, [sp, #3]
    mov     w0, #'m'
    strb    w0, [sp, #4]

    mov     x0, #1
    mov     x1, sp
    mov     x2, #5
    mov     x16, #SYS_WRITE
    svc     #0x80

    add     sp, sp, #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

_main:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    mov     x29, sp

    // Clear screen
    adrp    x0, clear_screen@PAGE
    add     x0, x0, clear_screen@PAGEOFF
    mov     x1, #7
    bl      write_str

    // Hide cursor
    adrp    x0, hide_cursor@PAGE
    add     x0, x0, hide_cursor@PAGEOFF
    mov     x1, #6
    bl      write_str

    // Draw pattern
    mov     x19, #0             // y = 0

row_loop:
    cmp     x19, #HEIGHT
    b.ge    done_drawing

    mov     x20, #0             // x = 0

col_loop:
    cmp     x20, #WIDTH
    b.ge    next_row

    // Calculate distance from center
    // dx = x - WIDTH/2, dy = y - HEIGHT/2
    sub     x21, x20, #(WIDTH/2)    // dx
    sub     x22, x19, #(HEIGHT/2)   // dy

    // Simple pattern: (x + y + x*y/8) mod 8 for color
    add     x23, x20, x19           // x + y
    mul     x24, x20, x19           // x * y
    lsr     x24, x24, #3            // / 8
    add     x23, x23, x24
    and     x23, x23, #7            // mod 8

    // Set color
    mov     x0, x23
    bl      set_color_full

    // Choose character based on pattern
    // Use distance-ish calculation for char selection
    mul     x21, x21, x21           // dx^2
    mul     x22, x22, x22           // dy^2
    add     x21, x21, x22           // dx^2 + dy^2

    // Select char based on "distance"
    lsr     x21, x21, #4            // scale down
    and     x21, x21, #7            // mod 8

    adrp    x0, chars@PAGE
    add     x0, x0, chars@PAGEOFF
    ldrb    w0, [x0, x21]
    bl      write_char

    add     x20, x20, #1
    b       col_loop

next_row:
    // Newline
    mov     x0, #'\n'
    bl      write_char

    add     x19, x19, #1
    b       row_loop

done_drawing:
    // Reset color
    adrp    x0, reset_color@PAGE
    add     x0, x0, reset_color@PAGEOFF
    mov     x1, #4
    bl      write_str

    // Show cursor
    adrp    x0, show_cursor@PAGE
    add     x0, x0, show_cursor@PAGEOFF
    mov     x1, #6
    bl      write_str

    // Newline
    mov     x0, #'\n'
    bl      write_char

    // exit(0)
    mov     x0, #0
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    mov     x16, #SYS_EXIT
    svc     #0x80

.data
chars:          .ascii " .:-=+*#@"
clear_screen:   .ascii "\x1b[2J\x1b[H"
hide_cursor:    .ascii "\x1b[?25l"
show_cursor:    .ascii "\x1b[?25h"
reset_color:    .ascii "\x1b[0m"
esc_color:      .ascii "\x1b[3"
newline:        .ascii "\n"
