.global _start

.section .data
input_buffer:   .space 256
output_buffer:  .space 256

.equ STDIN, 0
.equ STDOUT, 1
.equ EXIT, 1

.section .text
_start:
    MOV R0, STDIN          @ File descriptor: stdin
    LDR R1, =input_buffer  @ Buffer to read into
    MOV R2, #256           @ Number of bytes to read
    MOV R7, #3             @ System call number for read
    SWI 0                  @ Invoke system call

    MOV R1, #0             @ Initialize register R1 to 0 (index for input buffer)

parse_loop:
    LDRB R3, [R1], #1      @ Load the next byte from the input buffer into R3
    CMP R3, #0             @ Check if the byte is NULL (end of input)
    BEQ exit_program       @ If it is, exit the program

    CMP R3, #10            @ Check if the byte is a newline character
    BEQ parse_loop         @ If it is, skip to the next iteration

    STRB R3, [R1], #1      @ Store the byte into the output buffer

    B parse_loop           @ Continue the loop

exit_program:
    MOV R0, STDOUT         @ File descriptor: stdout
    LDR R1, =output_buffer @ Buffer to write from
    MOV R2, #256           @ Number of bytes to write
    MOV R7, #4             @ System call number for write
    SWI 0                  @ Invoke system call

    BL interpret           @ Interpret the instructions

    MOV R7, EXIT            @ System call number for exit
    SWI 0                  @ Invoke system call

interpret:
    LDR R4, =output_buffer @ Load the address of the output buffer
    MOV R5, R4             @ Initialize a pointer for the result

interpret_loop:
    LDRB R6, [R4], #1      @ Load the next byte from the output buffer into R6
    CMP R6, #0             @ Check if the byte is NULL (end of output)
    BEQ interpret_done     @ If it is, interpret is done

    CMP R6, #32            @ Check if the byte is a space
    BEQ interpret_loop     @ If it is, skip to the next iteration

    BL execute_instruction @ Execute the instruction

    B interpret_loop       @ Continue the loop

interpret_done:
    BX LR                  @ Return from the interpret function

execute_instruction:
    CMP R6, #'+'           @ Check if the instruction is addition
    BEQ add_operation

    CMP R6, #'-'           @ Check if the instruction is subtraction
    BEQ sub_operation

    CMP R6, #'*'           @ Check if the instruction is multiplication
    BEQ mul_operation

    CMP R6, #'/'           @ Check if the instruction is division
    BEQ div_operation

    CMP R6, #'='           @ Check if the instruction is variable assignment
    BEQ assign_operation

    CMP R6, '#'           @ Check if the instruction is a comment
    BEQ skip_line

    B interpret_done       @ Unsupported instruction, exit

add_operation:
    LDR R6, [R5]           @ Load the value from the result pointer
    ADD R5, R5, #4         @ Move the result pointer to the next location
    LDR R7, [R5]           @ Load the next value from the result pointer
    ADD R4, R4, #2         @ Skip the space character
    ADD R5, R5, #4         @ Move the result pointer to the next location
    ADD R6, R6, R7         @ Perform addition
    STR R6, [R5]           @ Store the result back to the result pointer
    BX LR                  @ Return

sub_operation:
    @ Implement subtraction
    B interpret_done

mul_operation:
    @ Implement multiplication
    B interpret_done

div_operation:
    @ Implement division
    B interpret_done

assign_operation:
    @ Implement variable assignment
    B interpret_done

skip_line:
    MOV R4, #0             @ Reset the output buffer pointer to the beginning of the line
    BX LR                  @ Return