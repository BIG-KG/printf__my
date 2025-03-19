;:================================================
;: 0-Linux-nasm-64.s                   (c)Ded,2012
;:================================================

; nasm -f elf64 -l 1-nasm.lst 1-nasm.s  ;  ld -s -o 1-nasm 1-nasm.o

section .text

global test


printf__my: 
            pop  r13                    ;save back addres
            mov  r14, rsp               ;save rsp before pushing

            push r9 
            push r8 
            push rcx 
            push rdx 
            push rsi 
            push rdi  ;save all args to stack
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
            mov  rsi, rax                   ;rsi - current symb ptr

            mov  rdi,  nextfree
            add  rdi,  outputBuffer          ;rdi - dest symb ptr

            jmp  ckeckBuffer    

            movTobuffer:
            movsb

            ckeckBuffer:

            xor rsi, rsi  ; Исправлено: обнуляем rsi                    ;if EOS -> end 
            je   end

            lea rsi, [rel  BYTE [rel rsi], '%'                  ;if epecifize sibol -> call spec func
            call Specif

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
            
            ret


            

;INP:  RAX - buffer pointer, rbx - next argument 
;DES:  RSI, RDX, r15
;rdi to next free; rsi to next input; rbx to next el

Specif:
            inc  rsi

            lea rsi, [rel  BYTE [rel rsi], '%'         ;if is %%
            je   spec_proc
            lea rsi, [rel  BYTE [rel rsi], 'c'         ;if is %c
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
            lea rsi, [rel  r15, [rel rbx]         ;next arg to print buffer
            lea rsi, [rel  [rel rdi], r15b         
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
            add  r15, outputBuffer
            add  r15, rdi
            cmp  r15, outputBuffer + 255

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
            mov  rsi, outputBuffer
            mov  rdx, nextfree
            syscall

            xor  rdi, rdi

            ret


section .data
nextfree         dw  0

outputBuffer:    db  256 DUP(0)
bufferLen        equ $ - outputBuffer

