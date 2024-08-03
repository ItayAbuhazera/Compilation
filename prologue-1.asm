;;; prologue-1.asm
;;; The first part of the standard prologue for compiled programs
;;;
;;; Programmer: Mayer Goldberg, 2023

%define T_void 				0
%define T_nil 				1
%define T_char 				2
%define T_string 			3
%define T_closure 			4
%define T_undefined			5
%define T_boolean 			8
%define T_boolean_false 		(T_boolean | 1)
%define T_boolean_true 			(T_boolean | 2)
%define T_number 			16
%define T_integer			(T_number | 1)
%define T_fraction 			(T_number | 2)
%define T_real 				(T_number | 3)
%define T_collection 			32
%define T_pair 				(T_collection | 1)
%define T_vector 			(T_collection | 2)
%define T_symbol 			64
%define T_interned_symbol		(T_symbol | 1)
%define T_uninterned_symbol		(T_symbol | 2)

%define SOB_CHAR_VALUE(reg) 		byte [reg + 1]
%define SOB_PAIR_CAR(reg)		qword [reg + 1]
%define SOB_PAIR_CDR(reg)		qword [reg + 1 + 8]
%define SOB_STRING_LENGTH(reg)		qword [reg + 1]
%define SOB_VECTOR_LENGTH(reg)		qword [reg + 1]
%define SOB_CLOSURE_ENV(reg)		qword [reg + 1]
%define SOB_CLOSURE_CODE(reg)		qword [reg + 1 + 8]

%define OLD_RDP 			qword [rbp]
%define RET_ADDR 			qword [rbp + 8 * 1]
%define ENV 				qword [rbp + 8 * 2]
%define COUNT 				qword [rbp + 8 * 3]
%define PARAM(n) 			qword [rbp + 8 * (4 + n)]
%define AND_KILL_FRAME(n)		(8 * (2 + n))

%define MAGIC				496351

%macro ENTER 0
	enter 0, 0
	and rsp, ~15
%endmacro

%macro LEAVE 0
	leave
%endmacro

%macro assert_type 2
        cmp byte [%1], %2
        jne L_error_incorrect_type
%endmacro


; Define a macro to create a pair
%macro CREATE_PAIR 3
    ; Save the current value of rdi
    push rdi

    ; Move the size of the pair (TYPE_SIZE + WORD_SIZE*2) into rdi
    mov rdi, (17)

    ; Call the malloc function to allocate memory for the pair
    call malloc

    ; Restore the original value of rdi
    pop rdi

    ; Set the type of the newly allocated memory to T_pair
    mov byte [%1], T_pair

    ; Set the car (first element) of the pair
    mov SOB_PAIR_CAR (%1), %2

    ; Set the cdr (second element) of the pair
    mov SOB_PAIR_CDR (%1), %3

%endmacro


; Define a macro to handle more parameters
%macro HANDLE_MORE_PARAMS 1
    ; Load the real number of arguments (params + opt) into r8
    mov r8, qword [rsp + 8 * 2]

    ; Copy the value of r8 into r11
    mov r11, r8

    ; Load the length of params' into rdx
    mov rdx, %1

    ; Subtract the length of params' from the real number of arguments
    sub r8, rdx

    ; Save the number of opt into r10
    mov r10, r8

    ; Calculate the placement of the top of the frame
    add r11, 2

    ; Clear r9
    xor r9, r9

    ; Calculate the placement of the next param to add to the list
    mov r9, r11

    ; Load the next param to add to the list into rbx
    mov rbx, qword[rsp + 8*r9]

    ; Load sob_nil into rcx
    mov rcx, sob_nil

    ; Create a pair with the next param and sob_nil
    CREATE_PAIR rax,rbx,rcx

    ; Decrement the placement of the next param and the number of remaining params
    dec r9
    dec r8

    ; Check if all params have been added to the list
    cmp r8,0
    je %%end_more_params

    ; Start the loop to add the remaining params to the list
    %%pair_loop:
        ; Load the current pair into rcx
        mov rcx, rax

        ; Load the next param to add to the list into rbx
        mov rbx, qword[rsp + 8*r9]

        ; Create a pair with the next param and the current pair
        CREATE_PAIR rax,rbx,rcx

        ; Decrement the placement of the next param and the number of remaining params
        dec r9
        dec r8

        ; Check if all params have been added to the list
        cmp r8,0
        jg %%pair_loop

    ; End the loop to add params to the list
    %%end_more_params:
        ; Increment the placement of the bottom opt
        inc r9

        ; Add the list to the stack
        mov qword [rsp+8*r9], rax

        ; Update the real number of arguments
        mov qword [rsp + 8 * 2], %1
        inc qword [rsp+ 8 * 2]

        ; Calculate the number of elements we need to copy
        mov rsi, r9

        ; Decrement the number of opt
        dec r10

        ; Calculate the total number of elements (param + opt num + ret, lex , n)
        add r9, r10

        ; Calculate the address of the top of the stack (the address we want to copy into)
        mov rdi, r9
        mov rax, 8
        mul rdi
        mov rdi, rax
        add rdi, rsp

        ; Start the loop to copy elements
        %%args_copy_loop_1:
            ; Check if all elements have been copied
            cmp rsi, (-1)
            je %%finish_args_copy_loop_1

            ; Calculate the address of the next element to copy
            mov rbx, rsi
            mov rax, 8
            mul rbx
            mov rbx, rax
            add rbx, rsp

            ; Load the next element to copy
            mov rbx, [rbx]

            ; Copy the element
            mov [rdi], rbx

            ; Update the address for the next copy and the number of remaining copies
            sub rdi, 8
            dec rsi

            ; Jump back to the start of the loop
            jmp %%args_copy_loop_1

        ; Finish the loop to copy elements
        %%finish_args_copy_loop_1:
            ; Update rsp to point to the new bottom of the stack
            mov rax, 8
            mul r10
            mov r10, rax
            add rsp, r10
%endmacro

; Define a macro to handle exact number of parameters
%macro HANDLE_EXACT_PARAMS 1
    ; Load the number of parameters into r8
    mov r8, %1

    ; Calculate the number of elements we want to move down (params + 3)
    add r8, 3

    ; Copy the current stack pointer into rdx
    mov rdx, rsp

    ; Calculate the next address we want to copy into
    sub rdx, 8

    ; Initialize the placement to copy from
    mov r10, 0

    ; Start the loop to copy elements down
    %%copy_down_loop:
        ; Load the next element to copy
        mov r15, qword[rsp + 8 * r10]

        ; Copy the element down
        mov qword[rdx], r15

        ; Update the placement to copy from and the address to copy into
        inc r10
        add rdx, 8

        ; Check if all elements have been copied
        cmp r10, r8
        je %%finish_down_loop

        ; Jump back to the start of the loop
        jmp %%copy_down_loop

    ; End the loop to copy elements down
    %%finish_down_loop:
        ; Add sob_nil to the end of the copied elements
        mov qword[rdx], sob_nil

        ; Load the number of parameters into r11 and increment it
        mov r11, %1
        inc r11

        ; Update the number of parameters on the stack
        mov qword[rsp + 8 * 1], r11

        ; Move the stack pointer down to accommodate the copied elements
        sub rsp, 8
%endmacro


%define assert_void(reg)		assert_type reg, T_void
%define assert_nil(reg)			assert_type reg, T_nil
%define assert_char(reg)		assert_type reg, T_char
%define assert_string(reg)		assert_type reg, T_string
%define assert_symbol(reg)		assert_type reg, T_symbol
%define assert_interned_symbol(reg)	assert_type reg, T_interned_symbol
%define assert_uninterned_symbol(reg)	assert_type reg, T_uninterned_symbol
%define assert_closure(reg)		assert_type reg, T_closure
%define assert_boolean(reg)		assert_type reg, T_boolean
%define assert_integer(reg)		assert_type reg, T_integer
%define assert_fraction(reg)		assert_type reg, T_fraction
%define assert_real(reg)		assert_type reg, T_real
%define assert_pair(reg)		assert_type reg, T_pair
%define assert_vector(reg)		assert_type reg, T_vector

%define sob_void			(L_constants + 0)
%define sob_nil				(L_constants + 1)
%define sob_boolean_false		(L_constants + 2)
%define sob_boolean_true		(L_constants + 3)
%define sob_char_nul			(L_constants + 4)

%define bytes(n)			(n)
%define kbytes(n) 			(bytes(n) << 10)
%define mbytes(n) 			(kbytes(n) << 10)
%define gbytes(n) 			(mbytes(n) << 10)

section .data
