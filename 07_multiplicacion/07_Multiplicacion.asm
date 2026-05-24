; ============================================================
; 07_multiplicacion.asm - Multiplicacion por Sumas Sucesivas
;
; Autor: Julio Cesar Tapia Conteras
; Fecha: 20/05/2026
;
; Descripción:
; Este programa solicita dos números enteros y realiza
; la multiplicación mediante sumas sucesivas, sin utilizar
; la instrucción MUL o IMUL para el cálculo principal.
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

    ; Mensaje para el multiplicando
    msg_a db "Ingresa el multiplicando: "
    msg_a_l equ $ - msg_a

    ; Mensaje para el multiplicador
    msg_b db "Ingresa el multiplicador: "
    msg_b_l equ $ - msg_b

    ; Mensaje de resultado
    msg_res db "Resultado: "
    msg_res_l equ $ - msg_res

    ; Salto de línea CR/LF
    newline db 13,10

; ============================================================
; SECCIÓN DE DATOS NO INICIALIZADOS
; ============================================================
section .bss

    ; Buffer de entrada
    buf         resb 16

    ; Variable usada por WriteFile
    written     resd 1

    ; Handles de consola
    hStdOut     resd 1
    hStdIn      resd 1

    ; Buffer para convertir números a texto
    num_buf     resb 16

    ; Variable para guardar el multiplicando
    val_a       resd 1

; ============================================================
; SECCIÓN DE CÓDIGO
; ============================================================
section .text

; ============================================================
; SUBRUTINA: parse_num
;
; Entrada:
;   buf = cadena ASCII
;
; Salida:
;   EAX = número entero convertido
;
; Propósito:
;   Convertir texto decimal a entero
; ============================================================
parse_num:

    ; --------------------------------------------------------
    ; esi = inicio del buffer
    ; --------------------------------------------------------
    lea     esi, [buf]

    ; --------------------------------------------------------
    ; eax = acumulador del número
    ; --------------------------------------------------------
    xor     eax, eax

.p:

    ; --------------------------------------------------------
    ; Leer carácter actual
    ; --------------------------------------------------------
    movzx   ecx, byte [esi]

    ; --------------------------------------------------------
    ; Condición:
    ; Verificar si el carácter es un dígito
    ; --------------------------------------------------------
    cmp     cl, '0'
    jl      .done

    cmp     cl, '9'
    jg      .done

    ; --------------------------------------------------------
    ; Convertir ASCII a número
    ;
    ; Operación crítica:
    ; sub cl, '0'
    ; --------------------------------------------------------
    sub     cl, '0'

    ; --------------------------------------------------------
    ; Multiplicar acumulador por 10
    ;
    ; Operación crítica:
    ; imul eax, eax, 10
    ; --------------------------------------------------------
    imul    eax, eax, 10

    ; Sumar nuevo dígito
    add     eax, ecx

    ; Avanzar al siguiente carácter
    inc     esi

    ; Repetir ciclo
    jmp     .p

.done:
    ret

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
;   Convertir entero a texto ASCII
; ============================================================
print_num:

    ; --------------------------------------------------------
    ; Preservar registros
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

    ; Guardar dígito en buffer
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
    ; Calcular longitud del número
    ; --------------------------------------------------------
    lea     eax, [num_buf + 15]
    sub     eax, ebx

    ; --------------------------------------------------------
    ; Imprimir cadena convertida
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
; LEER MULTIPLICANDO
; ============================================================

    ; Mostrar mensaje
    push    0
    push    written
    push    msg_a_l
    push    msg_a
    push    dword [hStdOut]
    call    _WriteFile@20

    ; Leer número
    push    0
    push    written
    push    15
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

    ; Convertir texto a número
    call    parse_num

    ; Guardar multiplicando
    mov     [val_a], eax

; ============================================================
; LEER MULTIPLICADOR
; ============================================================

    ; Mostrar mensaje
    push    0
    push    written
    push    msg_b_l
    push    msg_b
    push    dword [hStdOut]
    call    _WriteFile@20

    ; Leer número
    push    0
    push    written
    push    15
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

    ; Convertir texto a número
    call    parse_num

    ; --------------------------------------------------------
    ; ecx = multiplicador
    ; --------------------------------------------------------
    mov     ecx, eax

    ; --------------------------------------------------------
    ; esi = multiplicando
    ; --------------------------------------------------------
    mov     esi, [val_a]

; ============================================================
; MULTIPLICACIÓN POR SUMAS SUCESIVAS
; ============================================================

    ; --------------------------------------------------------
    ; eax = acumulador del resultado
    ; --------------------------------------------------------
    xor     eax, eax

.mult_loop:

    ; --------------------------------------------------------
    ; Condición:
    ; Mientras ecx != 0
    ; --------------------------------------------------------
    test    ecx, ecx
    jz      .done

    ; --------------------------------------------------------
    ; Operación crítica:
    ; add eax, esi
    ;
    ; Suma el multiplicando repetidamente
    ; --------------------------------------------------------
    add     eax, esi

    ; Disminuir contador
    dec     ecx

    ; Repetir ciclo
    jmp     .mult_loop

; ============================================================
; IMPRIMIR RESULTADO
; ============================================================
.done:

    ; --------------------------------------------------------
    ; Guardar resultado temporalmente
    ; --------------------------------------------------------
    push    eax

    ; Mostrar mensaje de resultado
    push    0
    push    written
    push    msg_res_l
    push    msg_res
    push    dword [hStdOut]
    call    _WriteFile@20

    ; Recuperar resultado
    pop     eax

    ; Imprimir resultado numérico
    call    print_num

    ; --------------------------------------------------------
    ; Imprimir salto de línea
    ; --------------------------------------------------------
    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

; ============================================================
; FINALIZAR PROGRAMA
; ============================================================

    ; Salir del programa
    push    0
    call    _ExitProcess@4