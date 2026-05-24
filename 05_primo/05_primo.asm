; ============================================================
; 05_primo.asm - Detector de Numeros Primos
;
; Autor: Julio Cesar Tapia Contreras
; Fecha: 17/05/2026
;
; Descripción:
; Este programa solicita un número mayor a 1 y determina
; si es primo o compuesto utilizando divisiones sucesivas
; desde 2 hasta la raíz cuadrada del número.
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
    msg_input db "Ingresa un numero mayor a 1: "
    msg_input_l equ $ - msg_input

    ; Mensaje si el número es primo
    msg_primo db "El numero es primo",13,10
    msg_primo_l equ $ - msg_primo

    ; Mensaje si el número es compuesto
    msg_comp db "El numero es compuesto",13,10
    msg_comp_l equ $ - msg_comp

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

    ; --------------------------------------------------------
    ; Mostrar mensaje de entrada
    ;
    ; Entrada:
    ;   hStdOut
    ;
    ; Salida:
    ;   Mensaje mostrado en pantalla
    ;
    ; Propósito:
    ;   Solicitar número al usuario
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_input_l
    push    msg_input
    push    dword [hStdOut]
    call    _WriteFile@20

    ; --------------------------------------------------------
    ; Leer número desde teclado
    ;
    ; Entrada:
    ;   Teclado
    ;
    ; Salida:
    ;   Número almacenado en buf
    ;
    ; Propósito:
    ;   Capturar valor decimal
    ; --------------------------------------------------------
    push    0
    push    written
    push    15
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

; ============================================================
; CONVERTIR ASCII A ENTERO
; ============================================================

    ; esi = apuntador al buffer
    lea     esi, [buf]

    ; eax = acumulador del número
    xor     eax, eax

.parse_loop:

    ; --------------------------------------------------------
    ; Leer carácter actual
    ; --------------------------------------------------------
    movzx   ecx, byte [esi]

    ; --------------------------------------------------------
    ; Condición:
    ; Verificar si es un dígito válido
    ; --------------------------------------------------------
    cmp     cl, '0'
    jl      .parse_done

    cmp     cl, '9'
    jg      .parse_done

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
    jmp     .parse_loop

.parse_done:

    ; --------------------------------------------------------
    ; ebx = número final ingresado
    ; --------------------------------------------------------
    mov     ebx, eax

; ============================================================
; VALIDACIONES INICIALES
; ============================================================

    ; --------------------------------------------------------
    ; Caso especial:
    ; Si N < 2 entonces no es primo
    ; --------------------------------------------------------
    cmp     ebx, 2
    jl      .is_composite

    ; --------------------------------------------------------
    ; Caso especial:
    ; Si N = 2 entonces sí es primo
    ; --------------------------------------------------------
    cmp     ebx, 2
    je      .is_prime

; ============================================================
; INICIALIZAR DIVISOR
; ============================================================

    ; ecx = divisor actual
    mov     ecx, 2

; ============================================================
; BUCLE DE VERIFICACIÓN
; ============================================================
.prime_loop:

    ; --------------------------------------------------------
    ; Verificar si ecx * ecx > ebx
    ;
    ; Si se cumple, el número es primo
    ;
    ; Operación crítica:
    ; imul eax, eax
    ; --------------------------------------------------------
    mov     eax, ecx
    imul    eax, eax

    cmp     eax, ebx
    jg      .is_prime

    ; --------------------------------------------------------
    ; Realizar división:
    ; ebx / ecx
    ;
    ; Operación crítica:
    ; div ecx
    ;
    ; Residuo queda en EDX
    ; --------------------------------------------------------
    mov     eax, ebx
    xor     edx, edx
    div     ecx

    ; --------------------------------------------------------
    ; Condición:
    ; Si residuo = 0, el número es compuesto
    ; --------------------------------------------------------
    test    edx, edx
    jz      .is_composite

    ; --------------------------------------------------------
    ; Incrementar divisor
    ; --------------------------------------------------------
    inc     ecx

    ; Repetir ciclo
    jmp     .prime_loop

; ============================================================
; EL NÚMERO ES PRIMO
; ============================================================
.is_prime:

    ; --------------------------------------------------------
    ; Mostrar mensaje positivo
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_primo_l
    push    msg_primo
    push    dword [hStdOut]
    call    _WriteFile@20

    jmp     .fin

; ============================================================
; EL NÚMERO ES COMPUESTO
; ============================================================
.is_composite:

    ; --------------------------------------------------------
    ; Mostrar mensaje negativo
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_comp_l
    push    msg_comp
    push    dword [hStdOut]
    call    _WriteFile@20

; ============================================================
; FINALIZAR PROGRAMA
; ============================================================
.fin:

    ; --------------------------------------------------------
    ; Salir del programa
    ; --------------------------------------------------------
    push    0
    call    _ExitProcess@4