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

            jmp .testStackSize

            .cleenStack:                 ;remove args from stack if srgs in it
            pop r12

            .testStackSize:
            cmp r14, rsp                ;is args in stack
            ja  .cleenStack

            push r13                    

            ret

            
; rax - string 
; rbx - first argument

scan_no_spec:
            mov  rsi, rdi
            lea  rdi, [rel outputBuffer]
            

            jmp  ckeckBuffer    

            movTobuffer:
            movsb

            ckeckBuffer:

            cmp  BYTE [rsi], 0                    ;if EOS -> end 
            je   end

            cmp  BYTE [rsi], '%'                  ;if epecifize sibol -> call spec func
            jne  nospec
            call Specif
            jmp ckeckBuffer
            nospec:


            cmp  rdi,   outputBuffer + bufferLen  ;if end of outputbuffer -> clean buffer
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
            je   .spec_proc
            cmp  BYTE [rsi], 'c'         ;if is %c
            je   .spec_c

            cmp  BYTE [rsi], 'b'
            jne  .testHex
            mov  rdx, 1
            mov  r10, 0x1
            mov rax, [rbx]
            push rdi
            push r8
            call num_To_Hex_String
            pop  r8
            pop  rdi
            jmp .number

            .testHex:
            cmp  BYTE [rsi], 'x'
            jne  .testDec
            mov  rdx, 4
            mov  r10, 0xf
            mov rax, [rbx]
            push rdi 
            push r8 
            call num_To_Hex_String
            pop r8
            pop rdi
            jmp .number

            .testDec:
            cmp  BYTE [rsi], 'd'
            jne  .notNum
            mov rax, [rbx]
            push r8 
            call num_To_dec_String
            pop r8

            jmp .number

            .notNum:
            cmp  BYTE [rsi], 's'
            jne .notStringSpec
            push rax
            push r8
            push r12
            call save_print_string
            pop  r12
            pop  r8
            pop  rax
            add rbx, 8
            jmp .endOfspec

            .notStringSpec:


            .spec_proc:
            mov  r15, 1            
            call is_Enoth_space     ;is space enoth buffer
            mov  BYTE [rdi], '%'           ;% to print buffer
            add  rdi,8

            jmp .endOfspec


            .spec_c:
            mov  r15, 1
            call is_Enoth_space     ;is space enoth buffer
            mov  r15, [rbx]         ;next arg to print buffer
            mov  [rdi], r15b         
            add rdi, 8
            add rbx, 8              ;next_arg_ptr to next asrg 

            jmp .endOfspec

            .number:
            push rax 
            push rdx
            push r15
            push r12
            push r8 
            call save_Num_to_buffer
            pop  r8
            pop  r12
            pop  r15
            pop  rdx
            pop  rax
            add  rbx, 8


        .endOfspec:
        inc rsi
        ret


;
;r15 - max need Space
;rdi - destanition
;
;destr - rdx, r15, r12, rdi
;set rdi to srart to outputbuffer
is_Enoth_space:
            push rdi
            add  rdi, r15
            lea  r12, [rel outputBuffer]
            add  r12, bufferLen 

            cmp  rdi, r12
            jb   enoth_space

            pop rdi
            push rax
            push rsi
            call clean_buffer
            pop  rsi
            pop  rax

            enoth_space:
            pop rdi
            ret




;destr - rdx, rax, rsi, rdi, r12
;set rdi to stert of buffer
clean_buffer:
            mov  rdx, rdi                ;size = lestEl(rdi) - outputBuffer
            mov  rax, [rel outputBuffer]  
            sub  rdx, rax

            mov  rax, 0x01               ; typeOf syscall
            mov  rdi, 1                  ; stdout       -> output    
            lea  rsi, [rel outputBuffer] ; outputBuffer -> sourse 
            syscall

            lea  rdi, [rel outputBuffer]  
            ret

;rsi - source sting, rbx - pointer to next print arg, rdi- pointer to next arg 
;r15 - size
;destr - rax, rdx, r15, rdi,  r8, r9, r10, rcx
save_Num_to_buffer:
            .printNum:
            push r15
            call is_Enoth_space
            pop r15
            
            push rsi
            mov rcx, r15
            lea rsi, [rel numberBuffer]

            repe movsb

            pop rsi

            ret



;destr - r8, r9, r10, rcx, rdi,  r15
;IN:  rax - input number; rdx - ln(2); r10 - mask
;OUT: <numberBuffer> - string, r15 - lenof
num_To_Hex_String:
            lea  rdi, [rel numberBuffer]
            xor  rcx, rcx
            mov  r9,  rax
            mov  r8, 64     ; wide of register
            sub  r8, rdx
            jmp  .test 

            .repeat:
            sub  r8, rdx
            mov  r9, rax

            .test:
            push rcx
            mov  rcx, r8 
            shr  r9, cl
            pop  rcx
            and  r9, r10
            jz   .noNum
            jmp .findFirst
            .noNum:
        
            cmp  r8, 0
            jne  .repeat

            .findFirst:
            mov  rcx, r8
            push rcx


            .make:
            mov  r9, rax
            shr  r9, cl
            and  r9, r10

            cmp  r9b, 10
            jae  .More10 

            add  r9b,  '0'
            mov  [rdi], r9b
            inc  rdi
            jmp .less10

            .More10:
            sub  r9b, 10
            add  r9b, 'A'
            mov  [rdi], r9b
            inc  rdi

            .less10:
            cmp  rcx, 0
            je   .end

            sub  rcx, rdx
            jmp  .make

            .end:
            pop rax
            div dl
            xor r15, r15
            mov r15b, al
            inc r15


            ret 

;destr - r8, r9, r10, rcx, r15, r11
;IN:  rax - input number;
;OUT: <numberBuffer> - string, rax - lenof
num_To_dec_String:
            push rdx
            push rbx
            mov rbx, rax
            shr rax, 31
            cmp rax, 0           
            je  .aboveZero 

            mov  r15, 1            
            call is_Enoth_space     ;is space enoth buffer
            mov  BYTE [rdi], '-'           ;% to print buffer
            add  rdi, 8

            neg ebx
            .aboveZero:
            mov rax, rbx
            pop rbx

            push rdi

            push rdx
            xor rdx, rdx
            mov r8, 1
            lea rdi, [rel numberBuffer] 
            mov r9, rax
            xor r15, r15 
            
            .repeat:
            inc r15
            mov rax, r9
            div r8
            xor rdx, rdx
            cmp rax, 0
            jz .findRazr
            imul r8, 10
            jmp .repeat


            .findRazr:
            mov rax, r8
            cmp r8, 1
            je  .oneRazr
            mov r11, 10
            div r11
            xor rdx, rdx
            mov r8, rax
            dec r15
            .oneRazr:  ; now in r8 - max razr
            xor rcx, rcx
            mov rax,  r9
            jmp .body
            

            .afterTest:
            mov rax, r9
            push rax
            mov  rax, r8 
            div  r11
            xor rdx, rdx
            mov  r8,  rax
            pop  rax
            .body:
            div r8
            xor rdx, rdx
            sub rax,  rcx
            add rax,  '0'
            mov [rdi], al
            inc rdi
            sub rax,  '0'
            add rcx , rax
            imul rcx,  10 

            cmp  r8, 1
            jne .afterTest

            pop rdx
            pop rdi
            pop rdx

            ret


extern strlen
;rsi - source sting, rbx - pointer to next print arg, rdi- pointer to next arg 
;rcx - OutputType: 0 - bin, 1 - hex, 2 - dec
;destr - rdx, rax, _rsi_, rdi, r12, rcx, r8, r10
save_print_string:
        push rdi
        mov  rdi, [rbx] 

        push rsi 
        call strlen
        pop  rsi
        pop  rdi

        cmp  rax, bufferLen
        jb   .fits_in_buffer
        push rax
        push rsi
        call clean_buffer
        pop rsi
        mov r12, [rbx]
        syscall

        ret

        .fits_in_buffer:
        lea  rdx, [rel outputBuffer]
        add  rdx, bufferLen  
        sub  rdx, rdi

        cmp rbx, rax
        ja .fits_in_free
        push rdx
        call clean_buffer
        pop  rdx
        mov  rcx, rax
        mov  rsi, [rbx]
        repe movsb

        ret 

        .fits_in_free:
        mov  rcx, rax
        mov  r11, rsi
        mov  rcx, rax
        mov  rsi, [rbx]
        repe movsb
        mov  rsi, r11

        ret

section .data

numberBuffer:    db  65  DUP(0), 0
outputBuffer:    db  256 DUP(0), 0
bufferLen        equ $ - outputBuffer

