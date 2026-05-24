; ============================================================
; 09_analizador.asm
; Contador de Vocales, Consonantes y Digitos
;
; Autor: Julio Cesar Tapia Contreras
; Fecha: 20/05/2026
;
; Descripción:
; Este programa solicita una frase al usuario y analiza
; cada carácter para determinar la cantidad de:
;
; - Vocales
; - Consonantes
; - Dígitos
;
; ============================================================

global _start

extern _GetStdHandle@4
extern _WriteFile@20
extern _ReadFile@20
extern _ExitProcess@4

; ============================================================
; SECCIÓN DE DATOS INICIALIZADOS
; ============================================================
section .data

    ; Mensaje de entrada
    msg_input db "Ingresa una frase: "
    msg_input_l equ $ - msg_input

    ; Mensajes de resultados
    msg_voc db "Vocales:     "
    msg_voc_l equ $ - msg_voc

    msg_con db "Consonantes: "
    msg_con_l equ $ - msg_con

    msg_dig db "Digitos:     "
    msg_dig_l equ $ - msg_dig

    ; Salto de línea CR/LF
    newline db 13,10

; ============================================================
; SECCIÓN DE DATOS NO INICIALIZADOS
; ============================================================
section .bss

    ; Buffer para entrada de texto
    buf         resb 256

    ; Variable usada por WriteFile
    written     resd 1

    ; Handles de consola
    hStdOut     resd 1
    hStdIn      resd 1

    ; Buffer para imprimir números
    num_buf     resb 16

    ; Contadores
    cnt_voc     resd 1
    cnt_con     resd 1
    cnt_dig     resd 1

; ============================================================
; SECCIÓN DE CÓDIGO
; ============================================================
section .text

; ============================================================
; SUBRUTINA: print_num
;
; Entrada:
;   EAX = número a imprimir
;
; Salida:
;   Número mostrado en pantalla
;
; Propósito:
;   Convertir entero decimal a texto ASCII
; ============================================================
print_num:

    ; --------------------------------------------------------
    ; Guardar registros
    ; --------------------------------------------------------
    push    ebx
    push    ecx
    push    edx

    ; --------------------------------------------------------
    ; ebx = final del buffer
    ; --------------------------------------------------------
    lea     ebx, [num_buf + 15]

    ; Terminador nulo
    mov     byte [ebx], 0

    ; Divisor decimal
    mov     ecx, 10

    ; --------------------------------------------------------
    ; Caso especial:
    ; Si el número es 0
    ; --------------------------------------------------------
    test    eax, eax
    jnz     .div_loop

    dec     ebx
    mov     byte [ebx], '0'
    jmp     .pr

; ============================================================
; BUCLE DE CONVERSIÓN DECIMAL
; ============================================================
.div_loop:

    ; --------------------------------------------------------
    ; Preparar división
    ; --------------------------------------------------------
    xor     edx, edx

    ; --------------------------------------------------------
    ; Operación crítica:
    ; div ecx
    ;
    ; eax = cociente
    ; edx = residuo
    ; --------------------------------------------------------
    div     ecx

    ; Convertir residuo a ASCII
    add     dl, '0'

    ; Guardar dígito
    dec     ebx
    mov     [ebx], dl

    ; --------------------------------------------------------
    ; Condición:
    ; Repetir mientras eax != 0
    ; --------------------------------------------------------
    test    eax, eax
    jnz     .div_loop

; ============================================================
; IMPRIMIR NÚMERO
; ============================================================
.pr:

    ; --------------------------------------------------------
    ; Calcular longitud
    ; --------------------------------------------------------
    lea     eax, [num_buf + 15]
    sub     eax, ebx

    ; --------------------------------------------------------
    ; Imprimir número convertido
    ; --------------------------------------------------------
    push    0
    push    written
    push    eax
    push    ebx
    push    dword [hStdOut]
    call    _WriteFile@20

    ; --------------------------------------------------------
    ; Restaurar registros
    ; --------------------------------------------------------
    pop     edx
    pop     ecx
    pop     ebx

    ret

; ============================================================
; SUBRUTINA: es_vocal
;
; Entrada:
;   AL = carácter
;
; Salida:
;   ZF = 1 si es vocal
;   ZF = 0 si no es vocal
;
; Propósito:
;   Verificar si el carácter es vocal
; ============================================================
es_vocal:

    ; --------------------------------------------------------
    ; Comparar con vocales minúsculas
    ; --------------------------------------------------------
    cmp     al, 'a'
    je      .si

    cmp     al, 'e'
    je      .si

    cmp     al, 'i'
    je      .si

    cmp     al, 'o'
    je      .si

    cmp     al, 'u'
    je      .si

    ; --------------------------------------------------------
    ; Comparar con vocales mayúsculas
    ; --------------------------------------------------------
    cmp     al, 'A'
    je      .si

    cmp     al, 'E'
    je      .si

    cmp     al, 'I'
    je      .si

    cmp     al, 'O'
    je      .si

    cmp     al, 'U'
    je      .si

    ; --------------------------------------------------------
    ; No es vocal
    ;
    ; Operación crítica:
    ; or al, al
    ;
    ; Fuerza ZF = 0
    ; --------------------------------------------------------
    or      al, al
    ret

.si:

    ; --------------------------------------------------------
    ; Es vocal
    ;
    ; Operación crítica:
    ; xor al, al
    ;
    ; Fuerza ZF = 1
    ; --------------------------------------------------------
    xor     al, al
    ret

; ============================================================
; PUNTO DE ENTRADA PRINCIPAL
; ============================================================
_start:

    ; --------------------------------------------------------
    ; Obtener handle de entrada estándar
    ; --------------------------------------------------------
    push    -10
    call    _GetStdHandle@4
    mov     [hStdIn], eax

    ; --------------------------------------------------------
    ; Obtener handle de salida estándar
    ; --------------------------------------------------------
    push    -11
    call    _GetStdHandle@4
    mov     [hStdOut], eax

; ============================================================
; MOSTRAR MENSAJE DE ENTRADA
; ============================================================

    push    0
    push    written
    push    msg_input_l
    push    msg_input
    push    dword [hStdOut]
    call    _WriteFile@20

; ============================================================
; LEER FRASE DEL USUARIO
; ============================================================

    push    0
    push    written
    push    255
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

; ============================================================
; INICIALIZAR CONTADORES
; ============================================================

    mov     dword [cnt_voc], 0
    mov     dword [cnt_con], 0
    mov     dword [cnt_dig], 0

    ; esi = inicio del buffer
    lea     esi, [buf]

; ============================================================
; RECORRER CADA CARÁCTER
; ============================================================
.char_loop:

    ; --------------------------------------------------------
    ; Leer carácter actual
    ; --------------------------------------------------------
    movzx   eax, byte [esi]

    ; --------------------------------------------------------
    ; Condición:
    ; Finalizar al encontrar:
    ; - NULL
    ; - CR
    ; - LF
    ; --------------------------------------------------------
    cmp     al, 0
    je      .print_results

    cmp     al, 13
    je      .print_results

    cmp     al, 10
    je      .print_results

; ============================================================
; VERIFICAR SI ES DÍGITO
; ============================================================

    cmp     al, '0'
    jl      .check_letter

    cmp     al, '9'
    jg      .check_letter

    ; --------------------------------------------------------
    ; Incrementar contador de dígitos
    ; --------------------------------------------------------
    inc     dword [cnt_dig]

    jmp     .next_char

; ============================================================
; VERIFICAR SI ES LETRA
; ============================================================
.check_letter:

    ; --------------------------------------------------------
    ; Verificar rango ASCII de letras
    ; --------------------------------------------------------
    cmp     al, 'A'
    jl      .next_char

    cmp     al, 'z'
    jg      .next_char

    cmp     al, 'Z'
    jle     .is_letter

    cmp     al, 'a'
    jge     .is_letter

    ; Entre Z y a no es letra
    jmp     .next_char

; ============================================================
; VERIFICAR SI ES VOCAL O CONSONANTE
; ============================================================
.is_letter:

    ; --------------------------------------------------------
    ; Llamar subrutina es_vocal
    ; --------------------------------------------------------
    call    es_vocal

    ; --------------------------------------------------------
    ; Condición:
    ; Si ZF = 1 -> vocal
    ; --------------------------------------------------------
    jz      .vocal

    ; --------------------------------------------------------
    ; Incrementar consonantes
    ; --------------------------------------------------------
    inc     dword [cnt_con]

    jmp     .next_char

.vocal:

    ; --------------------------------------------------------
    ; Incrementar vocales
    ; --------------------------------------------------------
    inc     dword [cnt_voc]

; ============================================================
; SIGUIENTE CARÁCTER
; ============================================================
.next_char:

    ; Avanzar al siguiente byte
    inc     esi

    ; Repetir ciclo
    jmp     .char_loop

; ============================================================
; IMPRIMIR RESULTADOS
; ============================================================
.print_results:

; ============================================================
; MOSTRAR VOCALes
; ============================================================

    push    0
    push    written
    push    msg_voc_l
    push    msg_voc
    push    dword [hStdOut]
    call    _WriteFile@20

    mov     eax, [cnt_voc]
    call    print_num

    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

; ============================================================
; MOSTRAR CONSONANTES
; ============================================================

    push    0
    push    written
    push    msg_con_l
    push    msg_con
    push    dword [hStdOut]
    call    _WriteFile@20

    mov     eax, [cnt_con]
    call    print_num

    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

; ============================================================
; MOSTRAR DÍGITOS
; ============================================================

    push    0
    push    written
    push    msg_dig_l
    push    msg_dig
    push    dword [hStdOut]
    call    _WriteFile@20

    mov     eax, [cnt_dig]
    call    print_num

    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

; ============================================================
; FINALIZAR PROGRAMA
; ============================================================

    push    0
    call    _ExitProcess@4