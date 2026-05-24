; ============================================================
; 06_mayor_arreglo.asm - Busqueda del Numero Mayor en un Arreglo
;
; Autor: Julio Cesar Tapia COntreras
; Fecha: 17/05/2026
;
; Descripción:
; Este programa recorre un arreglo de números enteros y
; determina cuál es el valor más grande almacenado.
;
; ============================================================

global _start

extern _GetStdHandle@4
extern _WriteFile@20
extern _ExitProcess@4

; ============================================================
; SECCIÓN DE DATOS INICIALIZADOS
; ============================================================
section .data

    ; --------------------------------------------------------
    ; Arreglo de números enteros
    ; --------------------------------------------------------
    arreglo dd 45, 12, 78, 3, 99, 56, 23, 67, 11, 88

    ; Cantidad de elementos del arreglo
    LEN equ 10

    ; Mensaje de resultado
    msg_res db "El numero mayor es: "
    msg_res_l equ $ - msg_res

    ; Salto de línea CR/LF
    newline db 13,10

; ============================================================
; SECCIÓN DE DATOS NO INICIALIZADOS
; ============================================================
section .bss

    ; Variable usada por WriteFile
    written     resd 1

    ; Handle de salida estándar
    hStdOut     resd 1

    ; Buffer para convertir número a texto
    num_buf     resb 12

    ; Variable para almacenar el número máximo
    maximo      resd 1

; ============================================================
; SECCIÓN DE CÓDIGO
; ============================================================
section .text

; ============================================================
; PUNTO DE ENTRADA PRINCIPAL
; ============================================================
_start:

    ; --------------------------------------------------------
    ; Obtener handle de salida estándar
    ; --------------------------------------------------------
    push    -11
    call    _GetStdHandle@4
    mov     [hStdOut], eax

; ============================================================
; BUSCAR EL NÚMERO MAYOR EN EL ARREGLO
; ============================================================

    ; --------------------------------------------------------
    ; esi = dirección base del arreglo
    ; --------------------------------------------------------
    lea     esi, [arreglo]

    ; --------------------------------------------------------
    ; eax = primer elemento del arreglo
    ; Será considerado el máximo inicial
    ; --------------------------------------------------------
    mov     eax, [esi]

    ; --------------------------------------------------------
    ; ecx = índice del siguiente elemento
    ; --------------------------------------------------------
    mov     ecx, 1

; ============================================================
; BUCLE DE RECORRIDO DEL ARREGLO
; ============================================================
.loop:

    ; --------------------------------------------------------
    ; Condición:
    ; Si ecx >= LEN terminar recorrido
    ; --------------------------------------------------------
    cmp     ecx, LEN
    jge     .found

    ; --------------------------------------------------------
    ; Cargar elemento actual del arreglo
    ;
    ; Operación crítica:
    ; [esi + ecx*4]
    ;
    ; ecx*4 porque cada entero ocupa 4 bytes
    ; --------------------------------------------------------
    mov     ebx, [esi + ecx*4]

    ; --------------------------------------------------------
    ; Comparar elemento actual con máximo
    ; --------------------------------------------------------
    cmp     ebx, eax
    jle     .no_update

    ; --------------------------------------------------------
    ; Actualizar máximo si ebx > eax
    ; --------------------------------------------------------
    mov     eax, ebx

.no_update:

    ; --------------------------------------------------------
    ; Incrementar índice
    ; --------------------------------------------------------
    inc     ecx

    ; Repetir ciclo
    jmp     .loop

; ============================================================
; MÁXIMO ENCONTRADO
; ============================================================
.found:

    ; --------------------------------------------------------
    ; Guardar máximo en memoria
    ; --------------------------------------------------------
    mov     [maximo], eax

; ============================================================
; IMPRIMIR MENSAJE DE RESULTADO
; ============================================================

    ; --------------------------------------------------------
    ; Mostrar texto descriptivo
    ; --------------------------------------------------------
    push    0
    push    written
    push    msg_res_l
    push    msg_res
    push    dword [hStdOut]
    call    _WriteFile@20

; ============================================================
; CONVERTIR NÚMERO A TEXTO
; ============================================================

    ; --------------------------------------------------------
    ; Agregar CR y LF al final del buffer
    ; --------------------------------------------------------
    mov     byte [num_buf + 10], 13
    mov     byte [num_buf + 11], 10

    ; --------------------------------------------------------
    ; eax = número máximo a convertir
    ; --------------------------------------------------------
    mov     eax, [maximo]

    ; --------------------------------------------------------
    ; edi = posición final del buffer
    ; --------------------------------------------------------
    lea     edi, [num_buf + 9]

    ; --------------------------------------------------------
    ; ecx = divisor decimal
    ; --------------------------------------------------------
    mov     ecx, 10

    ; --------------------------------------------------------
    ; Caso especial:
    ; Si el número es 0
    ; --------------------------------------------------------
    test    eax, eax
    jnz     .convert_loop

    mov     byte [edi], '0'
    dec     edi
    jmp     .print_num

; ============================================================
; BUCLE DE CONVERSIÓN DECIMAL
; ============================================================
.convert_loop:

    ; --------------------------------------------------------
    ; Condición:
    ; Repetir mientras eax != 0
    ; --------------------------------------------------------
    test    eax, eax
    jz      .print_num

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

    ; Guardar carácter en buffer
    mov     [edi], dl

    ; Retroceder posición
    dec     edi

    ; Repetir ciclo
    jmp     .convert_loop

; ============================================================
; IMPRIMIR NÚMERO CONVERTIDO
; ============================================================
.print_num:

    ; --------------------------------------------------------
    ; edi quedó un byte antes del primer dígito
    ; Avanzar una posición
    ; --------------------------------------------------------
    inc     edi

    ; --------------------------------------------------------
    ; Calcular longitud del número
    ; --------------------------------------------------------
    lea     eax, [num_buf + 10]
    sub     eax, edi

    ; Agregar longitud de CR/LF
    add     eax, 2

    ; --------------------------------------------------------
    ; Imprimir número convertido
    ; --------------------------------------------------------
    push    0
    push    written
    push    eax
    push    edi
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