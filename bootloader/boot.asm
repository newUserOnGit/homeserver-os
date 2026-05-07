; Home Server OS Bootloader
; Simple bootloader for x86_64

[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov si, msg_boot
    call print_string

    ; Load kernel from disk
    mov ah, 0x02        ; Read sectors
    mov al, 0x10        ; Number of sectors
    mov ch, 0x00        ; Cylinder
    mov cl, 0x02        ; Sector
    mov dh, 0x00        ; Head
    mov bx, 0x1000      ; Destination
    int 0x13
    jc disk_error

    mov si, msg_kernel_loaded
    call print_string

    ; Switch to protected mode
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:protected_mode

disk_error:
    mov si, msg_disk_error
    call print_string
    jmp $

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

msg_boot db 'Home Server OS Bootloader v0.1', 13, 10, 0
msg_kernel_loaded db 'Kernel loaded successfully', 13, 10, 0
msg_disk_error db 'Disk read error!', 13, 10, 0

; GDT
gdt_start:
    dq 0x0000000000000000   ; Null descriptor

gdt_code:
    dw 0xFFFF               ; Limit
    dw 0x0000               ; Base (low)
    db 0x00                 ; Base (middle)
    db 10011010b            ; Access
    db 11001111b            ; Flags + Limit (high)
    db 0x00                 ; Base (high)

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[BITS 32]
protected_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x90000
    mov esp, ebp

    ; Jump to kernel
    jmp 0x1000

times 510-($-$$) db 0
dw 0xAA55
