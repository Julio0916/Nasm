; ============================================================
; 03_palindromo.asm - Validador de Cadenas Palíndromas
;
; Autor: Julio Cesar Tapia Contreras
; Fecha: 17/05/2026
;
; Descripción:
; Este programa solicita una cadena al usuario y determina
; si es un palíndromo comparando caracteres desde ambos
; extremos de la cadena.
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
    msg_input db "Ingresa una cadena: "
    msg_input_l equ $ - msg_input

    ; Mensaje si es palíndromo
    msg_yes db "Es palindromo",13,10
    msg_yes_l equ $ - msg_yes

    ; Mensaje si no es palíndromo
    msg_no db "No es palindromo",13,10
    msg_no_l equ $ - msg_no

; ============================================================
; SECCIÓN DE DATOS NO INICIALIZADOS
; ============================================================
section .bss

    ; Buffer para almacenar cadena ingresada
    buf         resb 128

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
    ;   Solicitar una cadena al usuario
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_input_l
    push    msg_input
    push    dword [hStdOut]
    call    _WriteFile@20

    ; --------------------------------------------------------
    ; Leer cadena desde teclado
    ;
    ; Entrada:
    ;   Teclado
    ;
    ; Salida:
    ;   Cadena almacenada en buf
    ;
    ; Propósito:
    ;   Capturar texto ingresado
    ; --------------------------------------------------------
    push    0
    push    written
    push    127
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

; ============================================================
; CALCULAR LONGITUD DE LA CADENA
; ============================================================

    ; esi = inicio del buffer
    lea     esi, [buf]

    ; ecx = contador de longitud
    xor     ecx, ecx

.len_loop:

    ; --------------------------------------------------------
    ; Leer carácter actual
    ; --------------------------------------------------------
    movzx   eax, byte [esi + ecx]

    ; --------------------------------------------------------
    ; Condiciones de finalización:
    ; - Carriage Return (13)
    ; - Line Feed (10)
    ; - Byte nulo (0)
    ; --------------------------------------------------------
    cmp     al, 13
    je      .len_done

    cmp     al, 10
    je      .len_done

    cmp     al, 0
    je      .len_done

    ; Incrementar longitud
    inc     ecx
    jmp     .len_loop

.len_done:

    ; --------------------------------------------------------
    ; ecx contiene la longitud de la cadena
    ; --------------------------------------------------------

    ; --------------------------------------------------------
    ; Validar si cadena vacía
    ; --------------------------------------------------------
    cmp     ecx, 0
    je      .not_palindrome

; ============================================================
; INICIALIZAR PUNTEROS DE COMPARACIÓN
; ============================================================

    ; --------------------------------------------------------
    ; esi = puntero izquierdo
    ; --------------------------------------------------------
    lea     esi, [buf]

    ; --------------------------------------------------------
    ; edi = puntero derecho
    ; --------------------------------------------------------
    lea     edi, [buf]

    ; --------------------------------------------------------
    ; Operación crítica:
    ; add edi, ecx
    ;
    ; Mueve edi al final de la cadena
    ; --------------------------------------------------------
    add     edi, ecx

    ; Retroceder una posición
    dec     edi

; ============================================================
; BUCLE DE COMPARACIÓN
; ============================================================
.compare_loop:

    ; --------------------------------------------------------
    ; Condición:
    ; Si los punteros se cruzan,
    ; la cadena es palíndromo
    ; --------------------------------------------------------
    cmp     esi, edi
    jge     .is_palindrome

    ; --------------------------------------------------------
    ; Cargar caracteres extremos
    ; --------------------------------------------------------
    movzx   eax, byte [esi]
    movzx   ebx, byte [edi]

    ; --------------------------------------------------------
    ; Comparar caracteres
    ; --------------------------------------------------------
    cmp     eax, ebx
    jne     .not_palindrome

    ; --------------------------------------------------------
    ; Avanzar puntero izquierdo
    ; Retroceder puntero derecho
    ; --------------------------------------------------------
    inc     esi
    dec     edi

    ; Repetir comparación
    jmp     .compare_loop

; ============================================================
; CADENA ES PALÍNDROMO
; ============================================================
.is_palindrome:

    ; --------------------------------------------------------
    ; Mostrar mensaje positivo
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_yes_l
    push    msg_yes
    push    dword [hStdOut]
    call    _WriteFile@20

    jmp     .fin

; ============================================================
; CADENA NO ES PALÍNDROMO
; ============================================================
.not_palindrome:

    ; --------------------------------------------------------
    ; Mostrar mensaje negativo
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_no_l
    push    msg_no
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