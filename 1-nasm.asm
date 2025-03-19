;:================================================
;: 0-Linux-nasm-64.s                   (c)Ded,2012
;:================================================

; nasm -f elf64 -l 1-nasm.lst 1-nasm.s  ;  ld -s -o 1-nasm 1-nasm.o

section .text

global printf__my

printf__my: 
            pop  r13                    ;save back addres
            mov  r14, rsp               ;save rsp before pushing

            push r9 
            push r8 
            push rcx 
            push rdx 
            push rsi    ;save all args to stack
            mov  rbx, rsp               ;save start of args

            call scan_no_spec

            jmp testStackSize

            cleenStack:                 ;remove args from stack if srgs in it
            pop r12

            testStackSize:
            cmp rsp, r14                ;is args in stack
            jb  cleenStack

            push r13                    

            ret

            
; rax - string 
; rbx - first argument

scan_no_spec:
            mov  rax, rdi

            mov  rsi, rdi
            
            lea  rdi, [rel outputBuffer]          ;rdi - dest symb ptr
            add  rdi, [nextfree]

            jmp  ckeckBuffer    

            movTobuffer:
            movsb

            ckeckBuffer:

            cmp  BYTE [rsi], 0                    ;if EOS -> end 
            je   end

            cmp  BYTE [rsi], '%'                  ;if epecifize sibol -> call spec func
            jne  nospec
            call Specif
            nospec:


            cmp  rdi,   outputBuffer + 256  ;if end of outputbuffer -> clean buffer
            jbe  skip_buffer_clean
            push rax
            push rsi
            call clean_buffer
            pop  rsi
            pop  rax
            skip_buffer_clean:

            jmp movTobuffer

            end:

            call clean_buffer

            ret


            

;INP:  RAX - buffer pointer, rbx - next argument 
;DES:  RSI, RDX, r15
;rdi to next free; rsi to next input; rbx to next el

Specif:
            inc  rsi

            cmp  BYTE [rsi], '%'         ;if is %%
            je   spec_proc
            cmp  BYTE [rsi], 'c'         ;if is %c
            je   spec_c


            spec_proc:
            mov  r15, 1            
            call is_Enoth_space     ;is space enoth buffer
            mov  rdi, '%'           ;% to print buffer
            inc  rdi

            jmp endOfspec


            spec_c:
            mov  r15, 1
            call is_Enoth_space     ;is space enoth buffer
            mov  r15, [rbx]         ;next arg to print buffer
            mov  [rdi], r15b         
            inc rdi
            add rbx, 8              ;next_arg_ptr to next asrg 

            jmp endOfspec


        endOfspec:
        inc rsi
        ret


;
;r15 - max need Space
;rdi - destanition
;
;destr - rdx, r15
;
is_Enoth_space:
            lea  r15, [rel outputBuffer]
            mov  r12, r15
            add  r15, rdi
            add  r12, 255 
            cmp  r15, r12

            jb   enoth_space

            push rax
            push rsi
            call clean_buffer
            pop  rsi
            pop  rax

            enoth_space:
            ret




;destr - rdx, rax, rsi
;set rdi to stert of buffer
clean_buffer:
            mov  rax, 0x01      
            mov  rdi, 1 
            lea  r12, [rel outputBuffer]         
            mov  rsi, r12
            lea  rdx, [rel nextfree]
            syscall

            xor  rdi, rdi
            ret

;rsi - source sting, rbx - pointer to next print arg, rdi- pointer to next arg 
;destr - rax
print_num:
            mov rax, [rbx]
            shr rax, 63

            cmp rax, 0
            je  aboveZero 

            


section .data
nextfree         dq  0

outputBuffer:    db  256 DUP(0), 0
bufferLen        equ $ - outputBuffer

