bits    16
org     0x100

start:
    call    init_video
    call    init_keyboard

.loop:
    call    update_screen
    call    wait_frame

    cmp     byte [quit], 1

    jne     .loop

.exit:
    call    restore_video
    call    restore_keyboard

    mov     ah, 0x4c
    mov     al, 0x0
    int     0x21

quit:       db 0        ;; = 1 if ESC pressed
                        ;;      else 0 

%include "video.asm"
%include "keyboard.asm"
