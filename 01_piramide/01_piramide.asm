; ============================================================
; 01_piramide.asm - Generador de Pirámide Centrada
;
; Autor: Julio Cesar Tapia Contreras
; Fecha: 17/05/2026
;
; Descripción:
; Este programa solicita al usuario un número del 1 al 9
; y genera una pirámide centrada utilizando asteriscos.
;
; ============================================================

global _start

extern _GetStdHandle@4
extern _WriteConsoleA@20
extern _ReadConsoleA@20
extern _ExitProcess@4

; ============================================================
; SECCIÓN DE DATOS INICIALIZADOS
; ============================================================
section .data

    ; Mensaje de entrada para el usuario
    msg_input db "Ingresa el numero de filas (1-9): ",0
    msg_input_l equ $ - msg_input - 1

    ; Buffer reutilizable para imprimir un carácter
    char_buf db ' ',0

    ; Salto de línea CR/LF
    newline db 13,10

; ============================================================
; SECCIÓN DE DATOS NO INICIALIZADOS
; ============================================================
section .bss

    ; Buffer para lectura del teclado
    buf         resb 16

    ; Variable usada por WriteConsoleA
    written     resd 1

    ; Handles de consola
    hStdOut     resd 1
    hStdIn      resd 1

    ; Número de filas ingresado por el usuario
    filas       resd 1

; ============================================================
; SECCIÓN DE CÓDIGO
; ============================================================
section .text

_start:

    ; --------------------------------------------------------
    ; Obtener handle de entrada estándar (teclado)
    ; --------------------------------------------------------
    push    -10
    call    _GetStdHandle@4
    mov     [hStdIn], eax

    ; --------------------------------------------------------
    ; Obtener handle de salida estándar (pantalla)
    ; --------------------------------------------------------
    push    -11
    call    _GetStdHandle@4
    mov     [hStdOut], eax

    ; --------------------------------------------------------
    ; Mostrar mensaje de entrada
    ;
    ; Entrada:
    ;   hStdOut -> consola
    ;
    ; Salida:
    ;   Mensaje en pantalla
    ;
    ; Propósito:
    ;   Solicitar número de filas al usuario
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_input_l
    push    msg_input
    push    dword [hStdOut]
    call    _WriteConsoleA@20

    ; --------------------------------------------------------
    ; Leer número ingresado por el usuario
    ;
    ; Entrada:
    ;   Teclado
    ;
    ; Salida:
    ;   Número almacenado en buffer
    ;
    ; Propósito:
    ;   Capturar cantidad de filas
    ; --------------------------------------------------------
    push    0
    push    written
    push    15
    push    buf
    push    dword [hStdIn]
    call    _ReadConsoleA@20

    ; --------------------------------------------------------
    ; Convertir ASCII a número entero
    ;
    ; Operación crítica:
    ;   sub eax, '0'
    ;
    ; Convierte el carácter ASCII a valor numérico
    ; --------------------------------------------------------
    movzx   eax, byte [buf]
    sub     eax, '0'

    ; Guardar número de filas
    mov     [filas], eax

    ; --------------------------------------------------------
    ; Inicializar contador de filas
    ;
    ; ebx = fila actual
    ; --------------------------------------------------------
    mov     ebx, 1

; ============================================================
; BUCLE PRINCIPAL DE FILAS
; ============================================================
.fila_loop:

    ; --------------------------------------------------------
    ; Condición del bucle:
    ; Mientras fila <= filas
    ; --------------------------------------------------------
    mov     eax, [filas]
    cmp     ebx, eax
    jg      .fin

    ; ========================================================
    ; CALCULAR ESPACIOS
    ; Fórmula:
    ; espacios = filas - fila
    ; ========================================================
    mov     eax, [filas]
    sub     eax, ebx

.space_loop:

    ; --------------------------------------------------------
    ; Condición:
    ; Repetir mientras eax > 0
    ; --------------------------------------------------------
    test    eax, eax
    jz      .do_stars

    ; --------------------------------------------------------
    ; Preservar registros usados en subrutina
    ; push/pop para no perder valores
    ; --------------------------------------------------------
    push    eax
    push    ebx

    ; Imprimir espacio
    mov     byte [char_buf], ' '

    push    0
    push    written
    push    1
    push    char_buf
    push    dword [hStdOut]
    call    _WriteConsoleA@20

    ; Restaurar registros
    pop     ebx
    pop     eax

    ; Decrementar contador de espacios
    dec     eax
    jmp     .space_loop

; ============================================================
; IMPRIMIR ASTERISCOS
; Fórmula:
; asteriscos = (2 * fila) - 1
; ============================================================
.do_stars:

    ; --------------------------------------------------------
    ; Operaciones críticas:
    ; add y dec para calcular:
    ; (2*fila)-1
    ; --------------------------------------------------------
    mov     eax, ebx
    add     eax, ebx
    dec     eax

.star_loop:

    ; --------------------------------------------------------
    ; Condición:
    ; Repetir mientras eax > 0
    ; --------------------------------------------------------
    test    eax, eax
    jz      .do_newline

    ; Preservar registros
    push    eax
    push    ebx

    ; Imprimir asterisco
    mov     byte [char_buf], '*'

    push    0
    push    written
    push    1
    push    char_buf
    push    dword [hStdOut]
    call    _WriteConsoleA@20

    ; Restaurar registros
    pop     ebx
    pop     eax

    ; Decrementar contador de asteriscos
    dec     eax
    jmp     .star_loop

; ============================================================
; IMPRIMIR SALTO DE LÍNEA
; ============================================================
.do_newline:

    ; Preservar ebx antes de llamada
    push    ebx

    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteConsoleA@20

    ; Restaurar ebx
    pop     ebx

    ; --------------------------------------------------------
    ; Siguiente fila
    ; --------------------------------------------------------
    inc     ebx
    jmp     .fila_loop

; ============================================================
; FINALIZAR PROGRAMA
; ============================================================
.fin:

    ; Salir del programa con código 0
    push    0
    call    _ExitProcess@4