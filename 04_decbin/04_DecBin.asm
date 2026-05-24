; ============================================================
; 04_dec_bin.asm - Conversor de Decimal a Binario
;
; Autor: Julio Cesar Tapia Contreras
; Fecha: 17/05/2026
;
; Descripción:
; Este programa solicita un número decimal entre 0 y 255
; y muestra su representación binaria de 8 bits.
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
    msg_input db "Ingresa un numero (0-255): "
    msg_input_l equ $ - msg_input

    ; Mensaje de resultado
    msg_result db "En binario: "
    msg_result_l equ $ - msg_result

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

    ; Buffer para almacenar bits binarios
    ; Máximo 8 bits para números 0-255
    bin_buf     resb 9

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
    ;   Solicitar número decimal
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
; CONVERTIR CADENA ASCII A ENTERO
; ============================================================

    ; esi = apuntador al buffer
    lea     esi, [buf]

    ; eax = acumulador del número decimal
    xor     eax, eax

.parse_loop:

    ; --------------------------------------------------------
    ; Leer carácter actual
    ; --------------------------------------------------------
    movzx   ecx, byte [esi]

    ; --------------------------------------------------------
    ; Condición:
    ; Verificar si el carácter está entre '0' y '9'
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
    ; Multiplicar número acumulado por 10
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
    ; ebx = número decimal final
    ; --------------------------------------------------------
    mov     ebx, eax

; ============================================================
; CONSTRUIR REPRESENTACIÓN BINARIA
; ============================================================

    ; edi = inicio de bin_buf
    lea     edi, [bin_buf]

    ; ecx = contador de bits
    mov     ecx, 8

; ============================================================
; BUCLE DE CONVERSIÓN A BINARIO
; ============================================================
.bit_loop:

    ; --------------------------------------------------------
    ; Copiar número a eax
    ; --------------------------------------------------------
    mov     eax, ebx

    ; --------------------------------------------------------
    ; Preservar contador
    ; --------------------------------------------------------
    push    ecx

    ; --------------------------------------------------------
    ; Calcular posición del bit
    ; --------------------------------------------------------
    dec     ecx

    ; --------------------------------------------------------
    ; Operación crítica:
    ; shr eax, cl
    ;
    ; Desplaza el bit deseado hacia la derecha
    ; --------------------------------------------------------
    shr     eax, cl

    ; --------------------------------------------------------
    ; Obtener únicamente el último bit
    ;
    ; Operación crítica:
    ; and eax, 1
    ; --------------------------------------------------------
    and     eax, 1

    ; Convertir bit a ASCII
    add     al, '0'

    ; Restaurar contador
    pop     ecx

    ; --------------------------------------------------------
    ; Calcular posición en el buffer
    ; --------------------------------------------------------
    mov     edx, 8
    sub     edx, ecx

    ; Guardar carácter binario
    mov     [edi + edx], al

    ; --------------------------------------------------------
    ; Decrementar contador de bits
    ; --------------------------------------------------------
    dec     ecx

    ; --------------------------------------------------------
    ; Condición:
    ; Repetir mientras ecx != 0
    ; --------------------------------------------------------
    jnz     .bit_loop

; ============================================================
; IMPRIMIR RESULTADO
; ============================================================

    ; --------------------------------------------------------
    ; Mostrar mensaje "En binario:"
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_result_l
    push    msg_result
    push    dword [hStdOut]
    call    _WriteFile@20

    ; --------------------------------------------------------
    ; Imprimir los 8 bits almacenados
    ; --------------------------------------------------------
    push    0
    push    written
    push    8
    push    bin_buf
    push    dword [hStdOut]
    call    _WriteFile@20

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