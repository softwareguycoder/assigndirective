; 
; FILENAME:     assigndirective.asm
; CREATED BY:   Brian Hart
; DATE:         16 Nov 2018
; PURPOSE:      Demonstrate the %assign directive and redefining the values of variables using it
;

SYS_EXIT    EQU 0x1                     ; syscall number for sys_exit
EXIT_OK     EQU 0x0                     ; exit code for successful program termination
EXIT_ERROR  EQU -0x1                    ; exit code for when the program has an error
SYS_WRITE   EQU 0x4                     ; syscall number for sys_write
STDIN       EQU 0x0                     ; file descriptor for the STDIN stream
STDOUT      EQU 0x1                     ; file descriptor for the STDOUT stream

%assign TOTAL   0x14                    ; set the TOTAL variable to have an initial variable of 20 decimal

section .text
    global _start                       ; must be declared for linker (ld)
   
_start:
    ; Now, we want to write a message saying 'The total is (#)' (msg1) where 
    ; in place of (#) we want to print the value of the TOTAL variable.
    ; Then we will demo the usage of the %assign directive again to change the 
    ; value of TOTAL.  Then we'll print the new value to the screen.
    mov     eax, SYS_WRITE                      ; syscall number for sys_write
    mov     ebx, STDOUT                         ; file descriptor for STDOUT
    mov     ecx, msg1                           ; msg1
    mov     edx, len1                           ; length of the newline
    int     0x80    
    
    mov     eax, TOTAL                          ; put the value of the TOTAL var into EAX
    xor     ecx,ecx                     ; set the value of cx to zero -- we will use cx as the counter
repeat_loop:
    ; do {
    xor     edx,edx                       ; set the value of dx to zero
    push    ecx                           ; save the loop counter
    mov     ecx,0xA                       ; put 0xA into ECX; total should already be in EAX
    div     ecx                           ; divide by the value in ECX which is 10
    pop     ecx                           ; restore saved value of ECX
    push    edx                           ; remainder is in the EDX register, save it to the stack
    inc     ecx                           ; counter++
    test    eax,eax                       ; check whether EAX == 0 (EAX holds the quotient of the div)
    jnz     repeat_loop                 ; } while (EAX != 0);
print_chars:
    ; get the current digit from the stack and then encode it as ASCII
    pop edx                                 ; take current digit off the stack, only the lower 8bits matter
    add edx, 0x30                           ; digit += 0x30.  ASCII codes for digits are 0x30...0x39 for zero through nine
    
    ; call the SYS_WRITE syscall to put the current ASCII code (digit) on the screen
    mov     eax, SYS_WRITE                  ; syscall number for sys_write (defined as a constant)
    mov     ebx, STDOUT             ; file descriptor for STDOUT
    push    ecx                     ; save the value of ECX (loop counter)
    mov     [output],edx                  ; message to be printed to the screen - value in DL (current ASCII code)
    mov     ecx,output
    mov     edx,0x1                  ; length of the message to be printed to the screen
    int     0x80
    pop     ecx                     ; restore the counter from the stack for looping
    loop    print_chars              ; loop back to the print_char label while decrementing ECX 
    ; when the loop ends here we are
    ; call the SYS_WRITE syscall to put the newline on the screen
    ; and then again to print a null terminator
    mov     eax, SYS_WRITE                  ; syscall number for sys_write (defined as a constant)
    mov     ebx, STDOUT             ; file descriptor for STDOUT
    mov     ecx, newline            ; newline char and null terminator
    mov     edx, newlineL           ; length of the newline
    int     0x80
    
    mov eax,SYS_EXIT                            ; system call number (sys_exit)
    mov ebx,EXIT_OK                             ; process exit code
    int 0x80                                    ; call kernel 
    
section .data                           ; static data
    msg1    db  'The total starts out as: ',0x0
    len1    equ $-msg1
    
    base_10 dw  0xA         ; define this value as a 8-bit word because TOTAL is 8-bits
    
    newline     db  0xA,0x0 ; to use as a line termination
    newlineL    equ $-newline
section .bss                            ; dynamically-changed variables
    ; TODO: Add dynamically-changed variables here
    output      resd    0x0
