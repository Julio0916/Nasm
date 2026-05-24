; ============================================================
; 08_par_impar.asm - Identificador de Numero Par o Impar
;
; Autor: Julio Cesar Tapia Contreras
; Fecha: 20/05/2026
;
; Descripción:
; Este programa solicita un número entero al usuario y
; determina si es par o impar utilizando operaciones
; bit a bit.
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
    msg_input db "Ingresa un numero entero: "
    msg_input_l equ $ - msg_input

    ; Mensaje para número par
    msg_par db "Es par",13,10
    msg_par_l equ $ - msg_par

    ; Mensaje para número impar
    msg_impar db "Es impar",13,10
    msg_impar_l equ $ - msg_impar

; ============================================================
; SECCIÓN DE DATOS NO INICIALIZADOS
; ============================================================
section .bss

    ; Buffer para entrada del usuario
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

; ============================================================
; MOSTRAR MENSAJE DE ENTRADA
; ============================================================

    ; --------------------------------------------------------
    ; Entrada:
    ;   hStdOut
    ;
    ; Salida:
    ;   Mensaje mostrado en pantalla
    ;
    ; Propósito:
    ;   Solicitar un número entero
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_input_l
    push    msg_input
    push    dword [hStdOut]
    call    _WriteFile@20

; ============================================================
; LEER ENTRADA DEL USUARIO
; ============================================================

    ; --------------------------------------------------------
    ; Entrada:
    ;   Teclado
    ;
    ; Salida:
    ;   Datos almacenados en buf
    ;
    ; Propósito:
    ;   Capturar número decimal
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

    ; --------------------------------------------------------
    ; esi = inicio del buffer
    ; --------------------------------------------------------
    lea     esi, [buf]

    ; --------------------------------------------------------
    ; eax = acumulador del número
    ; --------------------------------------------------------
    xor     eax, eax

.parse_loop:

    ; --------------------------------------------------------
    ; Leer carácter actual
    ; --------------------------------------------------------
    movzx   ecx, byte [esi]

    ; --------------------------------------------------------
    ; Condición:
    ; Verificar si el carácter es un dígito válido
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

    ; Repetir ciclo
    jmp     .parse_loop

.parse_done:

; ============================================================
; VERIFICAR SI EL NÚMERO ES PAR O IMPAR
; ============================================================

    ; --------------------------------------------------------
    ; Operación crítica:
    ; test eax, 1
    ;
    ; Verifica el bit menos significativo:
    ; 0 = par
    ; 1 = impar
    ; --------------------------------------------------------
    test    eax, 1

    ; --------------------------------------------------------
    ; Condición:
    ; Si el resultado NO es cero,
    ; el número es impar
    ; --------------------------------------------------------
    jnz     .impar

; ============================================================
; EL NÚMERO ES PAR
; ============================================================
.par:

    ; --------------------------------------------------------
    ; Mostrar mensaje "Es par"
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_par_l
    push    msg_par
    push    dword [hStdOut]
    call    _WriteFile@20

    jmp     .fin

; ============================================================
; EL NÚMERO ES IMPAR
; ============================================================
.impar:

    ; --------------------------------------------------------
    ; Mostrar mensaje "Es impar"
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_impar_l
    push    msg_impar
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