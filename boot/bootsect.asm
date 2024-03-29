[org 0x7c00]
KERNEL_OFFSET equ 0x1000

    mov [BOOT_DRIVE], dl ; BIOS set boot drive in 'dl' on boot
    mov bp, 0x9000
    mov sp, bp

    mov bx, MSG_REAL_MODE
    call print
    call print_nl

    call load_kernel    ; read the kernel
    call switch_to_pm   ; disable interrup, load GDT, switch to protected mode
    jmp $

%include "./boot/print.asm"
%include "./boot/print_hex.asm"
%include "./boot/disk.asm"
%include "./boot/gdt.asm"
%include "./boot/32bit-print.asm"
%include "./boot/switch_pm.asm"

[bits 16]
load_kernel:
    mov bx, MSG_LOAD_KERNEL 
    call print
    call print_nl

    mov bx, KERNEL_OFFSET; read from disk and store in address 0x1000
    mov dh, 40
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

[bits 32]
BEGIN_PM:
    mov ebx, MSG_PORT_MODE
    call print_string_pm
    call KERNEL_OFFSET; Call method for kernel
    jmp $


BOOT_DRIVE db 0
MSG_REAL_MODE db "OS Started in 16-bit Legacy Mode ****",0
MSG_PORT_MODE db "Switch to 32-bit Protected Mode Succeeds ",0
MSG_LOAD_KERNEL db "Loading Kernel into Memory",0

; padding
times 510-($-$$) db 0
dw 0xaa55