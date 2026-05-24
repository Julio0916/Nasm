; ============================================================
; 02_fibonacci.asm - Sucesión de Fibonacci Iterativa
;
; Autor: Julio Cesar Tapia Contreras
; Fecha: 17/05/2026
;
; Descripción:
; Este programa solicita al usuario una cantidad de términos
; entre 1 y 9 y muestra la sucesión de Fibonacci de manera
; iterativa.
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

    ; Mensaje solicitado al usuario
    msg_input db "Cuantos terminos de Fibonacci? (1-9): "
    msg_input_l equ $ - msg_input

    ; Separador entre números
    comma db ", "

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

    ; Buffer para conversión numérica
    num_buf     resb 16

; ============================================================
; SECCIÓN DE CÓDIGO
; ============================================================
section .text

; ============================================================
; SUBRUTINA: print_num
;
; Entrada:
;   EAX = número decimal a imprimir
;
; Salida:
;   Número mostrado en consola
;
; Propósito:
;   Convertir un entero a ASCII e imprimirlo
;
; Registros preservados:
;   EBX, ECX y EDX
; ============================================================
print_num:

    ; --------------------------------------------------------
    ; Preservar registros usados
    ; --------------------------------------------------------
    push    ebx
    push    ecx
    push    edx

    ; --------------------------------------------------------
    ; Inicializar apuntador al final del buffer
    ; --------------------------------------------------------
    lea     ebx, [num_buf + 15]

    ; Colocar terminador nulo
    mov     byte [ebx], 0

    ; Divisor decimal
    mov     ecx, 10

    ; --------------------------------------------------------
    ; Verificar si el número es cero
    ; --------------------------------------------------------
    test    eax, eax
    jnz     .div_loop

    ; Si es cero, almacenar carácter '0'
    dec     ebx
    mov     byte [ebx], '0'
    jmp     .do_print

; ============================================================
; BUCLE DE CONVERSIÓN DECIMAL
; ============================================================
.div_loop:

    ; --------------------------------------------------------
    ; Operación crítica:
    ; div ecx
    ;
    ; Divide EDX:EAX entre 10
    ; Cociente -> EAX
    ; Residuo -> EDX
    ; --------------------------------------------------------
    xor     edx, edx
    div     ecx

    ; Convertir residuo a ASCII
    add     dl, '0'

    ; Guardar dígito en buffer
    dec     ebx
    mov     [ebx], dl

    ; --------------------------------------------------------
    ; Condición:
    ; Repetir mientras EAX != 0
    ; --------------------------------------------------------
    test    eax, eax
    jnz     .div_loop

; ============================================================
; IMPRIMIR NÚMERO
; ============================================================
.do_print:

    ; --------------------------------------------------------
    ; Calcular longitud del número convertido
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
    ; Restaurar registros preservados
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

    ; --------------------------------------------------------
    ; Mostrar mensaje de entrada
    ;
    ; Entrada:
    ;   hStdOut
    ;
    ; Salida:
    ;   Mensaje en pantalla
    ;
    ; Propósito:
    ;   Solicitar cantidad de términos
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_input_l
    push    msg_input
    push    dword [hStdOut]
    call    _WriteFile@20

    ; --------------------------------------------------------
    ; Leer entrada del usuario
    ;
    ; Entrada:
    ;   Teclado
    ;
    ; Salida:
    ;   Número almacenado en buf
    ;
    ; Propósito:
    ;   Capturar cantidad de términos
    ; --------------------------------------------------------
    push    0
    push    written
    push    2
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

    ; --------------------------------------------------------
    ; Convertir ASCII a entero
    ;
    ; Operación crítica:
    ; sub ecx, '0'
    ; --------------------------------------------------------
    movzx   ecx, byte [buf]
    sub     ecx, '0'

    ; ========================================================
    ; INICIALIZAR VARIABLES DE FIBONACCI
    ; ========================================================

    ; esi = F(0)
    xor     esi, esi

    ; edi = F(1)
    mov     edi, 1

    ; ebx = contador de términos impresos
    xor     ebx, ebx

; ============================================================
; BUCLE PRINCIPAL DE FIBONACCI
; ============================================================
.fib_loop:

    ; --------------------------------------------------------
    ; Condición:
    ; Mientras ebx < ecx
    ; --------------------------------------------------------
    cmp     ebx, ecx
    jge     .fin

    ; --------------------------------------------------------
    ; Imprimir término actual
    ; --------------------------------------------------------

    ; Preservar registros
    push    ecx
    push    esi
    push    edi
    push    ebx

    ; EAX = número a imprimir
    mov     eax, esi
    call    print_num

    ; Restaurar registros
    pop     ebx
    pop     edi
    pop     esi
    pop     ecx

    ; Incrementar contador
    inc     ebx

    ; --------------------------------------------------------
    ; Verificar si ya se imprimieron todos
    ; --------------------------------------------------------
    cmp     ebx, ecx
    jge     .fin

    ; --------------------------------------------------------
    ; Imprimir separador ", "
    ; --------------------------------------------------------

    ; Preservar registros
    push    ecx
    push    esi
    push    edi
    push    ebx

    push    0
    push    written
    push    2
    push    comma
    push    dword [hStdOut]
    call    _WriteFile@20

    ; Restaurar registros
    pop     ebx
    pop     edi
    pop     esi
    pop     ecx

    ; --------------------------------------------------------
    ; Calcular siguiente término
    ;
    ; Fórmula:
    ; siguiente = esi + edi
    ;
    ; Operación crítica:
    ; add eax, edi
    ; --------------------------------------------------------
    mov     eax, esi
    add     eax, edi

    ; Actualizar valores Fibonacci
    mov     esi, edi
    mov     edi, eax

    ; Repetir ciclo
    jmp     .fib_loop

; ============================================================
; FINALIZAR PROGRAMA
; ============================================================
.fin:

    ; --------------------------------------------------------
    ; Imprimir salto de línea
    ; --------------------------------------------------------
    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

    ; --------------------------------------------------------
    ; Salir del programa
    ; --------------------------------------------------------
    push    0
    call    _ExitProcess@4