; ============================================================
; 10_mayus_minus.asm
; Conversor de Mayusculas a Minusculas
;
; Autor: Julio Cesar Tapia Contreras
; Fecha: 20/05/2026
;
; Descripción:
; Este programa solicita una cadena de texto y convierte
; todas las letras mayúsculas a minúsculas utilizando
; manipulación de caracteres ASCII.
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

    ; Cadena de ejemplo original
    msg_orig db "Cadena original:  HOLA MUNDO DESDE ENSAMBLADOR",13,10
    msg_orig_l equ $ - msg_orig

    ; Mensaje para mostrar la cadena convertida
    msg_conv db "Cadena convertida: "
    msg_conv_l equ $ - msg_conv

    ; Salto de línea CR/LF
    newline db 13,10

; ============================================================
; SECCIÓN DE DATOS NO INICIALIZADOS
; ============================================================
section .bss

    ; Buffer para almacenar texto ingresado
    buf         resb 128

    ; Variable usada por WriteFile
    written     resd 1

    ; Handles de consola
    hStdOut     resd 1
    hStdIn      resd 1

    ; Buffer temporal para imprimir un carácter
    char_out    resb 2

; ============================================================
; SECCIÓN DE CÓDIGO
; ============================================================
section .text

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
; MOSTRAR CADENA ORIGINAL
; ============================================================

    ; --------------------------------------------------------
    ; Entrada:
    ;   hStdOut
    ;
    ; Salida:
    ;   Cadena original mostrada en pantalla
    ;
    ; Propósito:
    ;   Mostrar ejemplo inicial
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_orig_l
    push    msg_orig
    push    dword [hStdOut]
    call    _WriteFile@20

; ============================================================
; MOSTRAR MENSAJE DE ENTRADA
; ============================================================

    ; --------------------------------------------------------
    ; Solicitar cadena al usuario
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_conv_l
    push    msg_conv
    push    dword [hStdOut]
    call    _WriteFile@20

; ============================================================
; LEER CADENA DEL USUARIO
; ============================================================

    ; --------------------------------------------------------
    ; Entrada:
    ;   Teclado
    ;
    ; Salida:
    ;   Texto almacenado en buf
    ;
    ; Propósito:
    ;   Capturar cadena de texto
    ; --------------------------------------------------------
    push    0
    push    written
    push    127
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

; ============================================================
; PREPARAR RECORRIDO DE CADENA
; ============================================================

    ; --------------------------------------------------------
    ; esi = inicio del buffer
    ; --------------------------------------------------------
    lea     esi, [buf]

; ============================================================
; RECORRER CADA CARÁCTER
; ============================================================
.loop:

    ; --------------------------------------------------------
    ; Leer carácter actual
    ; --------------------------------------------------------
    movzx   eax, byte [esi]

    ; --------------------------------------------------------
    ; Condición:
    ; Finalizar si se encuentra:
    ; - NULL
    ; - CR
    ; - LF
    ; --------------------------------------------------------
    cmp     al, 0
    je      .done

    cmp     al, 13
    je      .done

    cmp     al, 10
    je      .done

; ============================================================
; VERIFICAR SI ES MAYÚSCULA
; ============================================================

    ; --------------------------------------------------------
    ; Verificar límite inferior
    ; --------------------------------------------------------
    cmp     al, 'A'
    jl      .print_it

    ; --------------------------------------------------------
    ; Verificar límite superior
    ; --------------------------------------------------------
    cmp     al, 'Z'
    jg      .print_it

    ; --------------------------------------------------------
    ; Operación crítica:
    ; add al, 32
    ;
    ; Convierte mayúscula a minúscula
    ; usando tabla ASCII
    ; --------------------------------------------------------
    add     al, 32

; ============================================================
; IMPRIMIR CARÁCTER
; ============================================================
.print_it:

    ; --------------------------------------------------------
    ; Guardar carácter convertido
    ; --------------------------------------------------------
    mov     [char_out], al

    ; --------------------------------------------------------
    ; Guardar esi temporalmente
    ; --------------------------------------------------------
    push    esi

    ; --------------------------------------------------------
    ; Imprimir un carácter
    ; --------------------------------------------------------
    push    0
    push    written
    push    1
    push    char_out
    push    dword [hStdOut]
    call    _WriteFile@20

    ; --------------------------------------------------------
    ; Restaurar esi
    ; --------------------------------------------------------
    pop     esi

    ; --------------------------------------------------------
    ; Avanzar al siguiente carácter
    ; --------------------------------------------------------
    inc     esi

    ; Repetir ciclo
    jmp     .loop

; ============================================================
; FINALIZAR IMPRESIÓN
; ============================================================
.done:

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

    ; --------------------------------------------------------
    ; Salir del programa
    ; --------------------------------------------------------
    push    0
    call    _ExitProcess@4